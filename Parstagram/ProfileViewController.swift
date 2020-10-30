//
//  ProfileViewController.swift
//  Parstagram
//
//  Created by Justin Ralph on 10/29/20.
//

import UIKit
import Parse
import AlamofireImage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    var posts = [PFObject]()
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = posts[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileFeedCollectionViewCell", for: indexPath) as! ProfileFeedCollectionViewCell
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        cell.personalPic.af.setImage(withURL: url)
        return cell
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var Username: UILabel!
    
    @IBOutlet weak var ProfilePic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        ProfilePic.layer.cornerRadius = 60
        let user = PFUser.current()
        Username.text = user?.username
        //set profile pic from database
        let imageFile = user?["ProfilePic"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        ProfilePic.af.setImage(withURL: url)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author","comments","comments.author"])
        query.whereKey("author", equalTo: PFUser.current()!)
        query.order(byDescending:"createdAt")
        query.limit = 50
        query.findObjectsInBackground(){ (posts,error) in if posts != nil {
            self.posts = posts!
            self.collectionView.reloadData()
            print(posts ?? "sad")
        }else{
            print("boo")
        }
            
        }
    }
    
    @IBAction func onChangeProfilePic(_ sender: Any) {
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func openGallery()
   {
       if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
           let imagePicker = UIImagePickerController()
           imagePicker.delegate = self
           imagePicker.allowsEditing = true
           imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
           self.present(imagePicker, animated: true, completion: nil)
       }
       else
       {
           let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           self.present(alert, animated: true, completion: nil)
       }
   }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 500, height: 50)
        let scaledimage = image.af.imageAspectScaled(toFill: size)
        ProfilePic.image = scaledimage
        
        //update profile pic on parse
        let user = PFUser.current()
        let imageData = ProfilePic.image!.pngData()
        let file = PFFileObject(data: imageData!)
        user?.setObject(file as Any, forKey: "ProfilePic")
        ProfilePic.layer.cornerRadius = 60
        user?.saveInBackground{ (success, error) in if success{
            print("Saved!")
            self.dismiss(animated: true, completion: nil)
        }else{
            print("Error!")
        }
            
        }
        dismiss(animated: true, completion: nil)
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
