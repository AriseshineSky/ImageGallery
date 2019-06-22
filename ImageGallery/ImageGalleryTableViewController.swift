//
//  ImageGalleryTableViewController.swift
//  ImageGallery
//
//  Created by Sky on 6/13/19.
//  Copyright © 2019 OU. All rights reserved.
//

import UIKit

class ImageGalleryTableViewController: UITableViewController {
    
    private var gallerys: [String: [(URL, CGFloat)]] = ["nature":[], "city":[], "country":[]]
    
    private var galleryNames: [String] {
        return Array(gallerys.keys).sorted()
    }
    
    private var currentGallery: String = "natrue"
    var currentGalleryImages: [(URL, CGFloat)]? = nil {
        didSet {
            gallerys[currentGallery] = currentGalleryImages
        }
    }
    
    private var recentDeleted: [String: [(URL, CGFloat)]] = ["deleted": []]
    
    private var recentDeletedGalleryNames: [String] {
        return Array(recentDeleted.keys).sorted()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.selectRow(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: UITableView.ScrollPosition.top)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section:Int) -> String? {
        if section == 0 {
            return "Available"
        } else {
            return "Recent Deleted"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if section == 0 {
            return gallerys.count
        } else {
            return recentDeleted.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "galleryNameCell", for: indexPath)
        let title = indexPath.section == 0 ? galleryNames[indexPath.row]:
            recentDeletedGalleryNames[indexPath.row]
        cell.textLabel?.text = title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentGallery = galleryNames[indexPath.row]
        if indexPath.section == 0 {
            performSegue(withIdentifier: "showImageGallery", sender: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            return UISwipeActionsConfiguration(actions: [UIContextualAction(style: <#T##UIContextualAction.Style#>, title: "Make Available", handler: {[weak self] _,_,_ in let galleryName = self?.recentDeletedGalleryNames[indexPath.row]
                let images = self?.recentDeleted[galleryName!]
                self?.recentDeleted.removeValue(forKey: galleryName!)
                self?.gallerys[galleryName!] = images
            })])
        } else {
            return nil
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
//    Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.performBatchUpdates({
                let galleryName = galleryNames[indexPath.row]
                let images = gallerys[galleryName]
                gallerys.removeValue(forKey: galleryName)
                recentDeleted[galleryName] = images
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.insertRows(at: [IndexPath(row: recentDeletedGalleryNames.count - 1, section: 1)], with: <#T##UITableView.RowAnimation#>.automatic)
            })
        } else if editingStyle == .insert {
//             Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }


    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath, let imageGalleryVC = segue.destination.contains as? ImageGalleryViewController {
            let row = indexPath.row
            let galleryName = galleryNames[row]
            imageGalleryVC.images = gallerys[galleryName] ?? []
        }
    }
}

extension UIViewController {
    var content: UIViewController {
        if let navigationVC = self as? UINavigationController {
            return navigationVC.viewControllers.first ?? <#default value#>
        } else {
            return self
        }
    }
}
