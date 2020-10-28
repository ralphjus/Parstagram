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

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
        let post = posts[indexPath.row]
        let user = post["author"] as! PFUser
        cell.author.text = user.username
        cell.caption.text = (post["caption"] as! String)
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        cell.photo.af.setImage(withURL: url)
        self.refreshControl.endRefreshing()
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count {
            loadmore()
        }
    }
    
    @objc func onRefresh() {
        let query = PFQuery(className:"Posts")
        query.includeKey("author")
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
        query.includeKey("author")
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
    
    var posts = [PFObject]()
    var refreshControl: UIRefreshControl!
    var limit = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        StartAnimations()
        let query = PFQuery(className:"Posts")
        query.includeKey("author")
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
