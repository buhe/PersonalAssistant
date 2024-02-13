//
//  ContentView.swift
//  PersonalAssistant
//
//  Created by 顾艳华 on 2/10/24.
//

import SwiftUI
import CoreData
import MarkdownText
import LangChain

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @ObservedObject var viewModel: ViewModel
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        Task {
            let rss = RSSLoader(url: "https://www.douban.com/feed/people/130141537/interests")
            let r = await rss.load()
            print("🌈rss:\(r)")
        }
    }
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.model.messages, id: \.0.self) { item in
                    Section {
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                Image(systemName: "person")
                                MarkdownText(item.0)
                            }
                            Divider()
                            HStack(alignment: .top) {
                                Image(systemName: "bubble.left")
                                if let responce = item.1 {
                                    MarkdownText(responce)
                                } else {
                                    ProgressView()
                                }
                            }
                        }
                    }
                }
            }
            .markdownHeadingStyle(.custom)
            .markdownQuoteStyle(.custom)
            .markdownCodeStyle(.custom)
            .markdownInlineCodeStyle(.custom)
            .markdownOrderedListBulletStyle(.custom)
            .markdownUnorderedListBulletStyle(.custom)
            .markdownImageStyle(.custom)
            .listStyle(.plain)
            InputFieldView(viewModel: viewModel)
                .padding(.horizontal)
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView(viewModel: ViewModel()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
