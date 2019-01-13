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

    var vc = ViewController()
    var count = 0
    let context = AppDelegate.viewContext
    let persistentContainer = AppDelegate.persistentContainer
    var fetchedResultsController:NSFetchedResultsController<Images>!
    var titles: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            print(error)
//        }
        if count == 0 {
            let alert = UIAlertController(title: "No titles", message: "Please save photo titles from first page firstly to display!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        tableView.reloadData()
    }
    
    //fileprivate let persistentContainer: NSPersistentContainer = NSPersistentContainer(name: "Images")
    
//    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Images> = {
//        let fetchRequest = NSFetchRequest<Images>()
//        fetchRequest.entity = Images.entity()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
//                                             managedObjectContext: context,
//                                             sectionNameKeyPath: "title",
//                                             cacheName: nil)
//        frc.delegate = self
//        return frc
//    }()

    fileprivate func setupFetchedResultsController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
        //request.predicate = NSPredicate(format: "age = %@", "12")
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
        // #warning Incomplete implementation, return the number of sections0
//        print(self.fetchedResultsController.fetchedObjects?.count)
//        print(count)
        //return self.fetchedResultsController.fetchedObjects?.count ?? 0
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //print(fetchedResultsController.sections?[section].numberOfObjects)
        //return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        print(count)
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
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
