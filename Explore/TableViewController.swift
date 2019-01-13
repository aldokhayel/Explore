//
//  TableViewController.swift
//  FlickrFinder
//
//  Created by Abdulrahman on 10/01/2019.
//  Copyright © 2019 Abdulrahman. All rights reserved.
//

import UIKit
import CoreData
class TableViewController: UITableViewController {

    var vc = SearchViewController()
    var count = 0
    let context = AppDelegate.viewContext
    let persistentContainer = AppDelegate.persistentContainer
    var fetchedResultsController:NSFetchedResultsController<Images>!
    var titles: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        if count == 0 {
            let alert = UIAlertController(title: "No titles", message: "Please save photo titles from first page firstly to display!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        tableView.reloadData()
    }
    
    fileprivate func setupFetchedResultsController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print("--------------------")
                print(data.value(forKey: "title") as! String)
                print(data.value(forKey: "imageData") as! Data)
                print(data.value(forKey: "imageURL") as! String)
                count = count + 1
            }
        } catch {
            print("Failed")
        }
  }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print("--------------------")
                print(data.value(forKey: "title") as! String)
                print(data.value(forKey: "imageData") as! Data)
                print(data.value(forKey: "imageURL") as! String)
                self.titles.append(data.value(forKey: "title") as! String)
            }
            
        } catch {
            
            print("Failed")
        }
        cell.textLabel?.text = titles[indexPath.row]
        return cell
    }
}

extension TableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert: tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete: tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update: tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move: tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert: tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete: tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .move, .update: tableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
        }
    }
}
