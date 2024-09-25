//
//  ContentView.swift
//  testChallenge
//
//  Created by Wim Tanudjaja on 9/16/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FlickrViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // The search bar at the top
                SearchBar(searchTerm: $viewModel.searchTerm)
                
                // Check if the ViewModel is loading data
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else {
                    ImageGridView(viewModel: viewModel)
                }
            }
            .navigationTitle("Flickr Search")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
