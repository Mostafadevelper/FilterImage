
import UIKit

protocol SubFilterDelegate {
    func subFilterClicked(atIndex: Int)
}

class FilterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var btnFilter: UIButton!
    var delegate:SubFilterDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnFilter.backgroundColor = UIColor.clear
        self.btnFilter.clipsToBounds = true
        self.btnFilter.layer.cornerRadius = 22.0
        self.btnFilter.layer.borderWidth = 1.0
        self.btnFilter.layer.borderColor = UIColor.init(red: 201.0/255.0, green: 201.0/255.0, blue: 201.0/255.0, alpha:1.0).cgColor
    }
    
    @IBAction func didBtnFilterClicked(_ sender: UIButton) {
        delegate?.subFilterClicked(atIndex: sender.tag)
    }
    

}
