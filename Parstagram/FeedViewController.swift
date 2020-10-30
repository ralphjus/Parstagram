//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Justin Ralph on 10/22/20.
//

import UIKit
import Parse
import AlamofireImage
import Lottie
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0{
            

        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
        let user = post["author"] as! PFUser
        cell.author.text = user.username
        cell.caption.text = (post["caption"] as! String)
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        cell.photo.af.setImage(withURL: url)
        //Author profile pic
        let imageFile2 = user["ProfilePic"] as! PFFileObject
        let urlString2 = imageFile2.url!
        let url2 = URL(string: urlString2)!
        cell.authorPic.af.setImage(withURL: url2)
            cell.authorPic.layer.cornerRadius = 32.5
        self.refreshControl.endRefreshing()
        return cell
        } else if indexPath.row <= comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            
            cell.nameLabel.text = user.username
            let imageFile = user["ProfilePic"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            cell.commentPic.af.setImage(withURL: url)
            cell.commentPic.layer.cornerRadius = 32.5
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count {
            loadmore()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
        selectedPost = post
        }
    }
    
    @objc func onRefresh() {
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author","comments","comments.author"])
        query.order(byDescending:"createdAt")
        query.limit = limit
        query.findObjectsInBackground(){ (posts,error) in if posts != nil {
            self.posts = posts!
            self.tableView.reloadData()    }
        }
    }
    
    func loadmore(){
        limit += 20
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author","comments","comments.author"])
        query.order(byDescending:"createdAt")
        query.limit = limit
        query.findObjectsInBackground(){ (posts,error) in if posts != nil {
            self.posts = posts!
            self.tableView.reloadData()    }
        }
    }
    
    var animationView: AnimationView?
    var refresh = true

    func StartAnimations() {
        animationView = .init(name: "12440-share-on-instagram")
        animationView!.frame = CGRect(x:(view.frame.origin.x + (view.frame.width - 400) / 2), y:(view.frame.origin.y + (view.frame.height - 400) / 2), width: 400, height: 400)
        animationView!.contentMode = .scaleAspectFit
        view.addSubview(animationView!)
        view.superview?.bringSubviewToFront(animationView!)
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 20
        animationView!.play()
        //view.showAnimatedSkeleton()
    }
    
    @objc func StopAnimation(){
        animationView?.stop()
        animationView?.isHidden = true
        view.subviews.last?.removeFromSuperview()
        //view.hideSkeleton()
        refresh = false
    }

    @IBOutlet weak var tableView: UITableView!
    
    let commentBar = MessageInputBar()
    
    var showsCommentBar = false
    
    var selectedPost: PFObject!
    
    var posts = [PFObject]()
    var refreshControl: UIRefreshControl!
    var limit = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        commentBar.inputTextView.placeholder = "Add a comment."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)        
    }
    
    @objc func keyboardWillBeHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        StartAnimations()
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author","comments","comments.author"])
        query.order(byDescending:"createdAt")
        query.limit = limit
        query.findObjectsInBackground(){ (posts,error) in if posts != nil {
            self.posts = posts!
            self.tableView.reloadData()
            self.StopAnimation()
        }else{
            print("boo")
        }
            
        }
    }
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        let sceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        sceneDelegate.window?.rootViewController = loginViewController
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Create comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        selectedPost.add(comment, forKey: "comments")
        
        selectedPost.saveInBackground(){ (success, error) in
            if success{
                print("comment saved")
            } else{
               print("ope")
            }
        }
        tableView.reloadData()
        //clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
