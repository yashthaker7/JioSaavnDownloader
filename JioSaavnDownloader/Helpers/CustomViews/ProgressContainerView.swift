//
//  ProgressContainerView.swift
//  JioSaavnDownloader
//
//  Created by Yash on 05/06/22.
//

import UIKit

class ProgressContainerView: UIView {
    
    public var progress: Double = 0 {
        didSet {
            progressBar.progress = progress
        }
    }
    
    private lazy var progressBar: TYProgressBar = {
        let progressBar = TYProgressBar()
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.gradients = [.systemBlue, .systemBlue]
        progressBar.textColor = .systemBlue
        progressBar.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        progressBar.lineDashPattern = [1, 0]   // lineWidth, lineGap
        progressBar.lineHeight = 5
        return progressBar
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        addSubview(progressBar)
        
        progressBar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        progressBar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        progressBar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        progressBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
