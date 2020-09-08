//
//  TrailsTableView.swift
//  MapKitTestProject
//
//  Created by Collin Browse on 8/21/20.
//  Copyright © 2020 Collin Browse. All rights reserved.
//

import UIKit
import MapKit


protocol TrailsTableViewDelegate: class {
    func didTapTrail(trail: Trail)
    func didTapGetDirections(trail: Trail)
}


class TrailsTableView : UITableView {
    
    var trails = [Trail]()
    var trailDelegate: TrailsTableViewDelegate?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setUpTableView()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    convenience init(delegate: TrailsTableViewDelegate, frame: CGRect, style: UITableView.Style) {
        self.init(frame: frame, style: style)
        self.trailDelegate = delegate
    }
    
    
    func setUpTableView() {
        delegate = self
        dataSource = self
        translatesAutoresizingMaskIntoConstraints = false
        register(UITableViewCell.self, forCellReuseIdentifier: "trailsTableViewCell")
    }
    
    
    func setTrails(trails: [Trail]) {
        self.trails = trails
    }
}




extension TrailsTableView: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trails.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "trailsTableViewCell", for: indexPath)
        cell.accessoryType = .detailButton
        cell.textLabel!.text = trails[indexPath.row].name
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trail = trails[indexPath.row]
        trailDelegate?.didTapTrail(trail: trail)
    }
    
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let trail = trails[indexPath.row]
        trailDelegate?.didTapGetDirections(trail: trail)
    }
    
}
