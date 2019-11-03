

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SubFilterDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var filteredImage: UIImage?
    var originalImage: UIImage?
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var secondaryMenu: UICollectionView!
    @IBOutlet var bottomMenu: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet var compareButton: UIButton!
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var filterIntensitySlider: UISlider!
    
    var IsFilterAppliedYet:Bool = false
    var prevSliderValue:Float = 0.0
    let filtersList = ["Red", "Green", "Blue", "GrayScale", "Brightness", "Contrast", "BlackAndWhite", "Negative"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = imageView.image{
            originalImage = image
        }
        // secondary menu
        secondaryMenu.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        secondaryMenu.dataSource = self
        secondaryMenu.delegate = self
        
        // Intensity slider
        filterIntensitySlider.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        filterIntensitySlider.translatesAutoresizingMaskIntoConstraints = false
        filterIntensitySlider.value = 0.0
        
        compareButton.isEnabled = false
        editButton.isEnabled = false
        
        //Long Gesture
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.toggleImage(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func toggleImage(_ sender : UILongPressGestureRecognizer) {
        if IsFilterAppliedYet == true{
            if sender.state == .began{
                self.updateImageViewAndAnimate(image: originalImage!)
            }else if sender.state == .ended{
                if filteredImage != nil && filteredImage != originalImage{
                    self.updateImageViewAndAnimate(image: filteredImage!)
                }
            }
        }
    }
    
    @IBAction func onEdit(_ sender: UIButton) {
        if self.compareButton.isSelected{
            self.updateImageViewAndAnimate(image: filteredImage!)
            IsFilterAppliedYet = true
            self.compareButton.isSelected = false
        }
        self.hideSubViews()
        if (!sender.isSelected) {
            self.showFilterIntensitySlider()
            sender.isSelected = true
        }
    }
    
    
    @IBAction func onFilterIntensityChange(_ sender: UISlider) {
        if IsFilterAppliedYet == true{
            let myRGBAImage = RGBAImage.init(image: filteredImage!)!
            if prevSliderValue < sender.value{
                prevSliderValue = sender.value
                Filters.increaseBrightnessFilter(imageRGBA: myRGBAImage, Percentage: Double(sender.value), completionBlock: {(imgRGBA) -> Void in
                    self.filteredImage = imgRGBA!.toUIImage()
                    self.imageView.image = self.filteredImage
                })
            }else if prevSliderValue == sender.value{
                prevSliderValue = sender.value
            }else{
                prevSliderValue = sender.value
                Filters.decreaseBrightnessFilter(imageRGBA: myRGBAImage, Percentage: Double(sender.value), completionBlock: {(imgRGBA) -> Void in
                    self.filteredImage = imgRGBA!.toUIImage()
                    self.imageView.image = self.filteredImage
                })
            }
        }
    }
    
    
    @IBAction func onCompare(_ sender: UIButton) {
        self.hideSubViews()
        if (sender.isSelected) {
            self.updateImageViewAndAnimate(image: filteredImage!)
            IsFilterAppliedYet = true
            sender.isSelected = false
        }else{
            self.updateImageViewAndAnimate(image: originalImage!)
            IsFilterAppliedYet = false
            sender.isSelected = true
        }
    }
    

    // MARK: Share
    @IBAction func onShare(sender: AnyObject) {
        if self.compareButton.isSelected{
            self.updateImageViewAndAnimate(image: filteredImage!)
            IsFilterAppliedYet = true
            self.compareButton.isSelected = false
        }
        self.hideSubViews() // hide subviews if any
        let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", imageView.image!], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    // MARK: New Photo
    @IBAction func onNewPhoto(sender: AnyObject) {
        if self.compareButton.isSelected{
            self.updateImageViewAndAnimate(image: filteredImage!)
            IsFilterAppliedYet = true
            self.compareButton.isSelected = false
        }
        self.hideSubViews() // hide subviews if any
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)){
            let cameraPicker = UIImagePickerController()
            cameraPicker.delegate = self
            cameraPicker.sourceType = .camera
            present(cameraPicker, animated: true, completion: nil)
        }else{
            self.displayImageViewWithTextOverlay(text: "No Camera", imageView: self.imageView)
        }
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .photoLibrary
        present(cameraPicker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            var cropImage : UIImage?
            if image.size.width > 300 || image.size.height > 400
            {
                cropImage = self.imageWithImage(image: image, scaledToSize: CGSize(width: 300.0, height: 400.0))
            }
            else{
                cropImage = image
            }
            originalImage = cropImage
            imageView.image = originalImage
            IsFilterAppliedYet = false
            compareButton.isEnabled = false
            editButton.isEnabled = false
        }
    }
    
    func imageWithImage(image:UIImage ,scaledToSize newSize:CGSize)-> UIImage
    {
        UIGraphicsBeginImageContext( newSize )
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return newImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Filter Menu
    @IBAction func onFilter(sender: UIButton) {
        if self.compareButton.isSelected{
            self.updateImageViewAndAnimate(image: filteredImage!)
            IsFilterAppliedYet = true
            self.compareButton.isSelected = false
        }
        self.hideSubViews()
        if (!sender.isSelected) {
            showSecondaryMenu()
            sender.isSelected = true
        }
    }
    
    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        let bottomConstraint = secondaryMenu.bottomAnchor.constraint(equalTo: bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraint(equalTo: view.rightAnchor)
        
        let heightConstraint = secondaryMenu.heightAnchor.constraint(equalToConstant: 44)
        
        NSLayoutConstraint.activate([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.secondaryMenu.alpha = 1.0
        }
    }
    
    func resetSecondaryMenu() {
        self.secondaryMenu.reloadData()
    }
    
    // MARK: UICollectionView DelegateFlowLayout & DataSource methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 44.0, height: 44.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filtersList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:FilterCollectionViewCell = secondaryMenu.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCollectionViewCell
        let image = UIImage(named: filtersList[indexPath.row])
        cell.btnFilter.setBackgroundImage(image, for: .normal)
        cell.btnFilter.tag = 100 + indexPath.row
        cell.delegate = self
        return cell
    }
    
    func updateImageViewAndAnimate(image: UIImage) {
        if image == originalImage{
            self.displayImageViewWithTextOverlay(text: "Original Image", imageView: self.imageView)
        }
        self.imageView.image = image
        let transition = CATransition.init()
        transition.duration = 1.0
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = .fade
        self.imageView.layer.add(transition, forKey: nil)
    }
    
    func displayImageViewWithTextOverlay(text:String, imageView: UIImageView) {
        let toastView:UILabel = UILabel()
        toastView.text = text
        toastView.textColor = UIColor.white
        toastView.backgroundColor = UIColor.orange.withAlphaComponent(0.7)
        toastView.textAlignment = NSTextAlignment.center
        toastView.font = UIFont.systemFont(ofSize: 24)
        toastView.frame = CGRect.init(x: self.view.bounds.size.width/2 - 70, y: 20, width: 160, height: 40)
        toastView.layer.cornerRadius = 10
        toastView.layer.masksToBounds = true
        imageView.addSubview(toastView)
        self.perform(#selector(hideToast(toastView:)), with: toastView, afterDelay: 0.5)
    }
    
    @objc func hideToast(toastView:UILabel)
    {
        UIView.animate(withDuration: 4.0, animations: {
            toastView.alpha = 0.0
        }) { (finished:Bool) in
            if finished == true {
                toastView.removeFromSuperview()
            }
        }
    }
    
    
    func subFilterClicked(atIndex: Int) {
        let filterIndex = atIndex - 100
        IsFilterAppliedYet = true
        compareButton.isEnabled = true
        editButton.isEnabled = true
        self.applyFilter(atIndex: filterIndex)
    }
    
    func applyFilter(atIndex: Int) {
        let myRGBA = RGBAImage.init(image: originalImage!)!
        Filters.applyDefaultFilters(image: myRGBA, name: self.filtersList[atIndex], completionBlock: {(imgRGBA) -> Void in
            self.filteredImage = imgRGBA!.toUIImage()
            self.updateImageViewAndAnimate(image: self.filteredImage!)
        })
    }
    
    func showFilterIntensitySlider() {
        view.addSubview(filterIntensitySlider)
        let bottomConstraint = filterIntensitySlider.bottomAnchor.constraint(equalTo: bottomMenu.topAnchor)
        let leftConstraint = filterIntensitySlider.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = filterIntensitySlider.rightAnchor.constraint(equalTo: view.rightAnchor)
        
        let heightConstraint = filterIntensitySlider.heightAnchor.constraint(equalToConstant: 44)
        
        NSLayoutConstraint.activate([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.filterIntensitySlider.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.filterIntensitySlider.alpha = 1.0
        }
    }
    
    
    func hideSubViews() {
        for subview in self.view.subviews{
            self.hideViewWithAnimation(sender: subview)
        }
    }
    
    func hideViewWithAnimation(sender: AnyObject) {
        if sender.isKind(of: UICollectionView.self){
            UIView.animate(withDuration: 0.4, animations: {
                self.secondaryMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.resetSecondaryMenu()
                    self.secondaryMenu.removeFromSuperview()
                    self.filterButton.isSelected = false
                }
            }
        }
        if sender.isKind(of: UISlider.self){
            UIView.animate(withDuration: 0.4, animations: {
                self.filterIntensitySlider.alpha = 0
            }) { completed in
                if completed == true {
                    self.filterIntensitySlider.value = 0.0
                    self.filterIntensitySlider.removeFromSuperview()
                    self.editButton.isSelected = false
                }
            }
        }
    }

}

