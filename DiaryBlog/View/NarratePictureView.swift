//
//  NarratePictureView.swift
//  DiaryBlog
//
//  Created by imac-2437 on 2024/1/18.
//

import SwiftUI
import PhotosUI

struct NarratePictureView: View {
    @State var imagesView = ["Picture0", "Picture1", "Picture2", "Picture3"]
    @State private var selection = 0  // 加入一个State变量用于存储当前页码
    var body: some View {
        TabView(selection: $selection) { // 通过selection绑定当前的选中页
            ForEach(imagesView.indices, id: \.self) { index in
                Image(imagesView[index])
                    .resizable()
                    .scaledToFill()
                    .aspectRatio(contentMode: .fit) // 保持内容的宽高比
                    .frame(width: UIScreen.main.bounds.width)
                    .clipped()
                    .tag(index) // 给每个页面一个唯一的标识，使得TabView能区分
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)) // 使TabView按页滚动
        .frame(height: 440)
    }
}

//struct NarratePictureView_Previews: PreviewProvider {
//    static var previews: some View {
//        NarratePictureView()
//    }
//}
