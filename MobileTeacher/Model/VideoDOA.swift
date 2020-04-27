//
//  VideoDOA.swift
//  MobileTeacher
//
//  Created by james oeth on 2/12/20.
//  Copyright © 2020 Pavly Habashy. All rights reserved.
//

//class VideoDAO {
//    private let container: NSPersistentContainer
//
//    init(container: NSPersistentContainer) {
//        self.container = container
//    }
//
//    private func saveContext() {
//        try! container.viewContext.save()
//    }
//    
//    func makeInternallyStoredVideo(_ bitmap: UIImage) -> ImageBlobWithInternalStorage {
//        let image = insert(ImageBlobWithInternalStorage.self, into: container.viewContext)
//        image.blob = bitmap.toData() as NSData?
//        saveContext()
//        return image
//    }
//
//    func internallyStoredVideo(by id: NSManagedObjectID) -> ImageBlobWithInternalStorage {
//        return container.viewContext.object(with: id) as! ImageBlobWithInternalStorage
//    }
//}
