//
//  InputPhoto.swift
//  DiaryBlog
//
//  Created by imac-2437 on 2024/1/19.
//

import SwiftUI
import PhotosUI

struct InputPhoto: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?
    
    var body: some View {
        ZStack {
            
            if let selectedPhotoData,
               let image = UIImage(data: selectedPhotoData) {
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            }
            PhotosPicker(selection: $selectedItem, matching: .any(of: [.images, .videos, .not(.livePhotos)])) {
                Label("Select a photo", systemImage: "photo")
            }
            .tint(.purple)
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .onChange(of: selectedItem, perform: {newIteam in
                Task {
                    if let data = try? await newIteam?.loadTransferable(type: Data.self ) {
                        selectedPhotoData = data
                    }
                }
            })
        }
    }
}


struct InputPhoto_Previews: PreviewProvider {
    static var previews: some View {
        InputPhoto()
    }
}
