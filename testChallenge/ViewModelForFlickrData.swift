//
//  ViewModelForFlickrData.swift
//  testChallenge
//
//  Created by Wim Tanudjaja on 9/16/24.
//

import Combine
import SwiftUI

class FlickrViewModel: ObservableObject {
    @Published var images: [FlickrImage] = []
    @Published var isLoading: Bool = false
    @Published var searchTerm: String = "" {
        didSet {
            // Perform the fetch whenever the search term changes
            fetchImages()
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // Function to fetch images from Flickr based on the search term
    func fetchImages() {
        guard !searchTerm.isEmpty else { return } // No search term, do not fetch
        
        isLoading = true
        
        // Replace spaces with commas for the API request
        let formattedSearchTerm = searchTerm.replacingOccurrences(of: " ", with: ",")
        let urlString = "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=\(formattedSearchTerm)"
        
        // Ensure the URL is valid
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        // Fetch data using URLSession
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: FlickrResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.isLoading = false
                case .failure(let error):
                    print("Error fetching images: \(error)")
                    self.isLoading = false
                }
            }, receiveValue: { [weak self] response in
                // Update images from the API response
                self?.images = response.items
            })
            .store(in: &cancellables)
    }
}


struct SearchBar: View {
    @Binding var searchTerm: String
    
    var body: some View {
        TextField("Search for images", text: $searchTerm)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal)
            .font(.body) // Dynamic Text Support for body text
            .accessibilityLabel("Image Search Bar")
            .accessibilityHint("Enter a word or comma-separated words to search for images on Flickr.")
    }
}



struct ImageGridView: View {
    @ObservedObject var viewModel: FlickrViewModel
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.images) { flickrImage in
                    NavigationLink(destination: ImageDetailView(image: flickrImage)) {
                        AsyncImage(url: URL(string: flickrImage.media.m)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipped()
                                    .accessibilityLabel("\(flickrImage.title) by \(cleanAuthor(flickrImage.author))")
                                    .accessibilityHint("Double tap to view details of this image.")
                            default:
                                Color.gray.frame(width: 150, height: 150)
                                    .accessibilityLabel("Placeholder image")
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    func cleanAuthor(_ author: String) -> String {
        if let start = author.range(of: "("), let end = author.range(of: ")") {
            let name = author[start.upperBound..<end.lowerBound]
            return String(name)
        }
        return author
    }
}


struct ImageDetailView: View {
    let image: FlickrImage
    @State private var isShareSheetPresented = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Display the image
                AsyncImage(url: URL(string: image.media.m)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .accessibilityLabel("\(self.image.title)")
                            .accessibilityHint("This is the full-sized image.")
                    default:
                        Color.gray
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Title with dynamic font
                Text(image.title)
                    .font(.title) // Dynamic title text
                    .padding(.top)
                    .accessibilityLabel("Title: \(image.title)")
                
                // Author with dynamic font
                Text("By \(cleanAuthor(image.author))")
                    .font(.subheadline) // Dynamic subheadline text
                    .foregroundColor(.gray)
                    .accessibilityLabel("Author: \(cleanAuthor(image.author))")
                
                // Description with dynamic font
                Text(cleanHTMLDescription(image.description))
                    .font(.body) // Dynamic body text
                    .padding(.top)
                    .accessibilityLabel("Description: \(cleanHTMLDescription(image.description))")
                
                // Published date with dynamic font
                Text("Published: \(formatDate(image.published))")
                    .font(.footnote) // Dynamic footnote text
                    .foregroundColor(.gray)
                    .padding(.top)
                    .accessibilityLabel("Published date: \(formatDate(image.published))")
                
                // Share button with dynamic font
                Button(action: {
                    isShareSheetPresented = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Image")
                            .font(.body) // Dynamic body text for button
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.top)
                .sheet(isPresented: $isShareSheetPresented, content: {
                    ShareSheet(items: [URL(string: image.media.m)!, image.title, cleanHTMLDescription(image.description), cleanAuthor(image.author)])
                })
            }
            .padding()
        }
        .navigationTitle("Image Detail")
    }
    
    // Helper functions remain the same
    func cleanAuthor(_ author: String) -> String {
        if let start = author.range(of: "("), let end = author.range(of: ")") {
            let name = author[start.upperBound..<end.lowerBound]
            return String(name)
        }
        return author
    }
    
    func cleanHTMLDescription(_ description: String) -> String {
        guard let data = description.data(using: .utf8) else { return description }
        let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
        return attributedString?.string ?? description
    }
    
    func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}




