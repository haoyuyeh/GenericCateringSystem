//
//  SectionHeader.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/10.
//

import UIKit

class SectionHeader: UITableViewHeaderFooterView {
    // MARK: Properties
    static var reuseIdentifier: String {
        return String(describing: SectionHeader.self)
    }
    
    let stackView = UIStackView()

    lazy var icon: UIImageView = {
       let img = UIImageView(image: UIImage(systemName: "truck.box.badge.clock"))
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    lazy var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SectionHeader {
    func setupView() {
        
        title.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor.systemOrange
        stackView.addArrangedSubview(title)
        
        addSubview(stackView)
        setupLayout()
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor ,constant: 0),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 5),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 5),
        ])
    }
}
