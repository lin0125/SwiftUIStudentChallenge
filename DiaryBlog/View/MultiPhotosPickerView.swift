//
//  MultiPhotosPickerView.swift
//  DiaryBlog
//
//  Created by imac-2437 on 2024/1/24.
//

import SwiftUI
import PhotosUI


struct MultiPhotosPickerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPhotosData: [Data] = []
    
    var body: some View {
        
        NavigationStack() {
            ScrollView {
                VStack {
                    ForEach(Array(selectedPhotosData.enumerated()), id: \.offset) {index, photoData in
                        if let image = UIImage(data: photoData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .aspectRatio(contentMode: .fit) // 保持内容的宽高比
                                .frame(width: UIScreen.main.bounds.width)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Photos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    PhotosPicker(selection: $selectedItems, maxSelectionCount: 5, matching: .any(of: [.images, .videos, .not(.livePhotos)])) {
                        Image(systemName: "photo.on.rectangle.angled")
                    }
                    .onChange(of: selectedItems) { newItems in
                        //                        selectedPhotosData.removeAll()
                        var newSavedURLs: [URL] = []
                        for newItem in newItems {
                            Task {
                                if let data = try? await newItem.loadTransferable(type: Data.self) {
                                    // 將圖片數據保存到文件系統
                                    selectedPhotosData.append(data)
                                    if let savedURL = saveImageToDocumentsDirectory(imageData: data) {
                                        // 保存或更新URL列表
                                        newSavedURLs.append(savedURL)
                                        
                                    }
                                }
                            }
                        }
                        // 這裡應該寫代碼將這些URL保存到你的持久化存儲中，如使用UserDefaults
                        let urlsStrings = newSavedURLs.map { $0.absoluteString }
                        UserDefaults.standard.set(urlsStrings, forKey: "savedImageURLs")
                        // 重要：确保此操作在所有图片处理后执行
                        DispatchQueue.main.async {
                            self.selectedItems.removeAll()
                        }
                    }
                }
            }
            .onAppear() {
            
            }
        }
    }
    func handlePickerItemsChange(newItems: [PhotosPickerItem]) {
            // 用于存储新的StoredImage对象的数组
            for newItem in newItems {
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        addImageToCoreData(imageData: data)
                    }
                }
            }
            // 清除选择的项
            DispatchQueue.main.async {
                self.selectedItems.removeAll()
            }
        }
    
    // 使用Core Data来保存imageData
        func addImageToCoreData(imageData: Data) {
            let newStoredImage = StoredImage(context: viewContext)
            newStoredImage.id = UUID()
            newStoredImage.imageData = imageData

            do {
                try viewContext.save()
            } catch {
                // 处理错误
                print("Could not save image to CoreData: \(error)")
            }
        }
    // 使用Core Data加载图片数据
        func loadPhotosDataFromCoreData() {
            let fetchRequest: NSFetchRequest<StoredImage> = StoredImage.fetchRequest()
            do {
                let results = try viewContext.fetch(fetchRequest)
                selectedPhotosData = results.compactMap { $0.imageData }
            } catch {
                // 处理错误
                print("Could not fetch images from CoreData: \(error)")
            }
        }

        // 需要在这里调用保存和加载函数
        var body: some View {
            // ... 其他代码 ...
            .onAppear() {
                loadPhotosDataFromCoreData()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    PhotosPicker(selection: $selectedItems, maxSelectionCount: 5, matching: .any(of: [.images, .videos, .not(.livePhotos)])) {
                        Image(systemName: "photo.on.rectangle.angled")
                    }
                    .onChange(of: selectedItems) { newItems in
                        handlePickerItemsChange(newItems: newItems)
                    }
                }
            }
        }
}

struct MultiPhotosPickerView_Preview: PreviewProvider {
    static var previews: some View {
        MultiPhotosPickerView()
    }
}

