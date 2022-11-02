//
//  MainView.swift
//  TTask
//
//  Created by Nuno Ferro on 31/10/2022.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: viewModel.movementIcon).font(.system(size: 56.0))
            HStack () {
                Text("Status: ")
                    .font(.title)
                Text(viewModel.movementLabel)
                    .font(.title)
            }
            .padding(.top, 5.0)
        }
        .alert(viewModel.notificationTitle, isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
