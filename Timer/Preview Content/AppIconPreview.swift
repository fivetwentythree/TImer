//
//  AppIconPreview.swift
//  Timer
//
//  Created by Lochana Perera on 24/12/2024.
//

import SwiftUI

struct AppIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [Color(red: 0.4, green: 0.2, blue: 0.9),
                            Color(red: 0.2, green: 0.1, blue: 0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                ))
            
            Image(systemName: "timelapse")
                .resizable()
                .scaledToFit()
                .padding(35)
                .foregroundStyle(.white)
                .symbolRenderingMode(.hierarchical)
        }
        .frame(width: 512, height: 512)
    }
}
#Preview {
    AppIcon()
}
