//
//  HistoryCell.swift
//  Rutio
//
//  Created by Kateřina Černá on 27.07.2021.
//

import UIKit
import CoreData

class HistoryCell: UITableViewCell {
    
    static let identifier = "HistoryCell"
    
    @IBOutlet weak var startStopLabel: UILabel!
    @IBOutlet weak var destinationStopLabel: UILabel!
    @IBOutlet weak var favouriteImage: UIImageView!
    let image1 = UIImage(named: "star.fill") as UIImage?
    let image2 = UIImage(named: "star") as UIImage?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func commonInit(start: String, destination: String) {
        startStopLabel.text = start
        destinationStopLabel.text = destination
        favouriteImage.image = UIImage(named: "star") as UIImage?
  
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let starButton = UIButton(type: .system)
        starButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        starButton.setImage(UIImage(named: "star"), for: .normal)
        starButton.tintColor = .yellow
        starButton.addTarget(self, action: #selector(handMarcAsFavourite), for: .touchUpInside)
        accessoryView = starButton
    }
    
    @objc private func handMarcAsFavourite(){
        print("Marking to favourite")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
