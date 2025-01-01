//
//  LiveStreamVC.swift
//  Live Stream Playback
//
//  Created by Gautam Variya on 21/12/24.
//

import UIKit
import Combine

class LiveStreamVC: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var collViewVideos: UICollectionView!
    @IBOutlet weak var tblViewComments: UITableView!
    @IBOutlet weak var tblViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewSendRose: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblSendRose: UILabel!
    @IBOutlet weak var lblRoseCount: UILabel!
    
    @IBOutlet weak var viewComment: UIView!
    @IBOutlet weak var txtFieldComment: UITextField!
    @IBOutlet weak var btnEmoji: UIButton!
    
    @IBOutlet weak var lblRose: UILabel!
    @IBOutlet weak var lblGift: UILabel!
    @IBOutlet weak var lblShareCount: UILabel!
    

    //MARK: - Variables
    private var viewModel = StreamDataViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private var arrVideos: [Video] = [] {
        didSet {
            collViewVideos.reloadData()
        }
    }
    private var arrComments: [Comment] = [] {
        didSet {
            arrCommentsToShow.insert(arrComments.first!, at: 0)
            tblViewComments.reloadData()
            loadCellsWithDelay()
        }
    }
    private var arrCommentsToShow: [Comment] = []
    private var indexComment = 1
    private var indexVideo = -1
    private var imgUrl = "https://fastly.picsum.photos/id/481/200/200.jpg?hmac=aHV2Sqt0kxr96SHgdwdUuP4mu3m_EuPdtnslgUnkd1Y"
    private var isFromEmoji = false
    
    //MARK: - Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Initial
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        addNotification()
        bindViewModel()
        setUpCollectionView()
        setUpTableView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Override Properties
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey] {
                let newsize  = newvalue as! CGSize
                tblViewHeight.constant = newsize.height
            }
        }
    }
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" && isFromEmoji {
                return mode
            }
        }
        return nil
    }
    
    //MARK: - Action Methods
    @IBAction func btnEmoji(_ sender: Any) {
        isFromEmoji = true
        txtFieldComment.becomeFirstResponder()
    }
    
    @IBAction func btnRose(_ sender: Any) {
    }
    
    @IBAction func btnGift(_ sender: Any) {
    }
    
    @IBAction func btnShare(_ sender: Any) {
    }
}

//MARK: - UI Setup
extension LiveStreamVC {
    
    private func setupUI()  {
        DispatchQueue.main.async {
            self.viewSendRose.layer.cornerRadius = self.viewSendRose.bounds.height / 2
            self.imgUser.layer.cornerRadius = self.imgUser.bounds.height / 2
            self.viewComment.layer.cornerRadius = self.viewComment.bounds.height / 2
        }
       
        imgUser.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "ic_user"))
        lblUserName.font = setCustomFont(.medium, 9)
        lblSendRose.font = setCustomFont(.medium, 9)
        lblRoseCount.font = setCustomFont(.heavyItalic, 12)
        
        txtFieldComment.font = setCustomFont(.regular, 12)
        lblRose.font = setCustomFont(.medium, 10)
        lblGift.font = setCustomFont(.medium, 10)
        lblShareCount.font = setCustomFont(.medium, 10)
        
        txtFieldComment.delegate = self
        txtFieldComment.attributedPlaceholder = NSAttributedString(
            string: "Comment",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "textColor")!]
        )
    }
}

//MARK: - Notification Center
extension LiveStreamVC {
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

//MARK: - KeyBoard Hide/Show
extension LiveStreamVC {
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            // Adjust the view's frame or content inset
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = -keyboardHeight
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // Restore the view's position
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
}

//MARK: - StreamDataViewModel Fetch Data
extension LiveStreamVC {
    
    private func bindViewModel() {
        // Observe the videos array
        viewModel.$videos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] video in
                self?.arrVideos = video
            }
            .store(in: &cancellables)
        
        // Observe the errorMessageVideo
        viewModel.$errorMessageVideo
            .compactMap { $0 } // Ignore nil values
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showError(errorMessage)
            }
            .store(in: &cancellables)
        
        // Observe the comments array
        viewModel.$comments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] comment in
                self?.arrComments = comment
            }
            .store(in: &cancellables)
        
        // Observe the errorMessageComment
        viewModel.$errorMessageComment
            .compactMap { $0 } // Ignore nil values
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showError(errorMessage)
            }
            .store(in: &cancellables)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


//MARK: - Collection View
extension LiveStreamVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // Collecion View SetUp
    func setUpCollectionView() {
        let nib = UINib(nibName: "VideoCollViewCell", bundle: nil)
        collViewVideos.register(nib, forCellWithReuseIdentifier: VideoCollViewCell.identifier)
        collViewVideos.contentInsetAdjustmentBehavior = .never
        
        collViewVideos.delegate = self
        collViewVideos.dataSource = self
    }
    
    // UICollectionViewDataSource methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollViewCell.identifier, for: indexPath) as! VideoCollViewCell
        let item = arrVideos[indexPath.row]
        cell.configure(item)
        if indexVideo == -1 && indexPath.row == 0 {
            cell.playVideo()
        }
        return cell
    }
    
    // UICollectionViewDelegateFlowLayout methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ScreenWidth, height: ScreenHeight)
    }
    
    // Scroll Index check for Play and Pause Videos
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageSide = self.collViewVideos.bounds.height
        let offset = scrollView.contentOffset.y
        let tempSelCell = Int(floor((offset - pageSide / 2) / pageSide) + 1)
        
        if tempSelCell != indexVideo
        {
            if indexVideo >= 0 {
                let indexpath = IndexPath(row: indexVideo, section: 0)
                if let cell = collViewVideos.cellForItem(at: indexpath) as? VideoCollViewCell {
                    cell.resetPlayer()
                }
            }
            indexVideo = tempSelCell
            
            let indexpath = IndexPath(row: indexVideo, section: 0)
            if let cell = collViewVideos.cellForItem(at: indexpath) as? VideoCollViewCell {
                cell.playVideo()
            }
        }
    }
}


//MARK: - Table View
extension LiveStreamVC: UITableViewDataSource, UITableViewDelegate {

    // Table View SetUp
    func setUpTableView() {
        let nib = UINib(nibName: "CommentTableViewCell", bundle: nil)
        tblViewComments.register(nib, forCellReuseIdentifier: CommentTableViewCell.identifier)
        tblViewComments.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        tblViewComments.delegate = self
        tblViewComments.dataSource = self
    }
    
    // Comment Load
    private func loadCellsWithDelay() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [self] timer in
            guard self.indexComment < self.arrComments.count else {
                indexComment = 0
                //timer.invalidate() // Stop the timer when all data is loaded
                return
            }
            
            // Add the next item to the data source
            if arrCommentsToShow.count == 1 {
                let comment = Comment(id: 1000, username: "user123", picURL: "", comment: "", isJoined: true)
                arrCommentsToShow.append(comment)
            } else {
                arrCommentsToShow.append(arrComments[indexComment])
            }
            
            removeOldCells()
            tblViewComments.reloadData()
            indexComment += 1
        }
    }
    
    private func removeOldCells() {
        if arrCommentsToShow.count > 5 {
            arrCommentsToShow.removeFirst()
        }
    }
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrCommentsToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as! CommentTableViewCell
        let item = arrCommentsToShow[indexPath.row]
        cell.configure(item)
        let isSetFade = arrCommentsToShow.count == 5 && indexPath.row == 0
        cell.setFading(isFade: isSetFade)
        return cell
    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: - UITextFieldDelegate
extension LiveStreamVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        txtFieldComment.inputView = nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !text.isEmpty {
            let comment = Comment(id: 2000, username: "user123", picURL: imgUrl, comment: text)
            arrCommentsToShow.append(comment)
            removeOldCells()
            tblViewComments.reloadData()
            txtFieldComment.text = ""
        }
        isFromEmoji = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
