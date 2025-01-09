//
//  HomeViewCell.swift
//  VPD Task
//
//  Created by Inyene on 1/9/25.
//

import UIKit


class RepositoryCell: UITableViewCell {
    static let identifier = String(describing: RepositoryCell.self)
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let ownerLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textColor = .secondaryLabel
        ownerLabel.font = .systemFont(ofSize: 14)
        ownerLabel.textColor = .secondaryLabel
        
        let labelsStack = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel, ownerLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 4
        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(labelsStack)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),
            
            labelsStack.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            labelsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            labelsStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            labelsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with repository: Repository) {
        nameLabel.text = repository.name.capitalized
         descriptionLabel.text = repository.description
        
         ownerLabel.text = "by \(repository.owner.login)"
         ownerLabel.textColor = .systemBlue
        
         let placeholder = UIImage(systemName: "person.circle.fill")
         if let avatarURL = URL(string: repository.owner.avatarUrl) {
             avatarImageView.kf.setImage(
                 with: avatarURL,
                 placeholder: placeholder,
                 options: [
                     .transition(.fade(0.2)),
                     .cacheOriginalImage
                 ]
             )
         } else {
             avatarImageView.image = placeholder
         }
     }
     
     override func prepareForReuse() {
         super.prepareForReuse()
         avatarImageView.kf.cancelDownloadTask()
         avatarImageView.image = nil
     }
}
