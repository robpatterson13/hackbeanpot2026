import SwiftUI
import Combine

// ViewModel that bridges the UI to AnimalManager and the Shop catalog
final class ShopViewModel: ObservableObject {
    @Published var selectedCategory: ShopCategory = .upgrades
    @Published private(set) var coins: Int
    
    private let animalManager: AnimalManager
    private let shop = Shop() // Catalog of items
    
    init(animalManager: AnimalManager) {
        self.animalManager = animalManager
        self.coins = animalManager.coins
    }
    
    var categories: [ShopCategory] { [.upgrades, .food, .accessories, .backgrounds] }
    
    func title(for category: ShopCategory) -> String {
        switch category {
        case .upgrades:     return "Upgrades"
        case .food:         return "Food"
        case .accessories:  return "Accessories"
        case .backgrounds:  return "Backgrounds"
        }
    }
    
    var filteredItems: [ShopItem] {
        shop.items.filter { $0.category == selectedCategory }
    }
    
    func canBuy(_ item: ShopItem) -> Bool {
        animalManager.canBuy(item)
    }
    
    func buy(_ item: ShopItem) throws {
        try animalManager.buy(item)
        // Reflect latest coins after purchase
        self.coins = animalManager.coins
    }
}

struct ShopView: View {
    @StateObject private var viewModel: ShopViewModel
    @State private var errorMessage: String? = nil
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    init(animalManager: AnimalManager) {
        _viewModel = StateObject(wrappedValue: ShopViewModel(animalManager: animalManager))
    }
    
    var body: some View {
        ZStack {
            // Use a subtle background that works with both light/dark
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Coins header
                HStack {
                    Label("Coins: \(viewModel.coins)", systemImage: "creditcard")
                        .font(.headline)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Capsule())
                    Spacer()
                }
                .padding(.horizontal)
                
                // Category picker
                Picker("Category", selection: $viewModel.selectedCategory) {
                    ForEach(viewModel.categories, id: \.self) { cat in
                        Text(viewModel.title(for: cat)).tag(cat)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Items grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Array(viewModel.filteredItems.enumerated()), id: \.offset) { _, item in
                            ShopItemCard(item: item,
                                         canBuy: viewModel.canBuy(item)) {
                                do {
                                    try viewModel.buy(item)
                                } catch AnimalManager.PurchaseError.insufficientFunds {
                                    errorMessage = "Not enough coins."
                                } catch AnimalManager.PurchaseError.invalidUpgrade {
                                    errorMessage = "This upgrade isn't unlocked yet."
                                } catch {
                                    errorMessage = "Couldn't complete purchase."
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
        }
        .navigationTitle("Shop")
        .alert("Purchase Failed", isPresented: .constant(errorMessage != nil), actions: {
            Button("OK") { errorMessage = nil }
        }, message: {
            Text(errorMessage ?? "")
        })
    }
}

struct ShopItemCard: View {
    let item: ShopItem
    let canBuy: Bool
    let onBuy: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Image / Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                
                contentImage
            }
            .frame(height: 110)
            
            // Title and price
            Text(item.displayName)
                .font(.headline)
                .lineLimit(1)
            
            HStack {
                Image(systemName: "creditcard")
                Text("\(item.cost)")
                Spacer()
                Button("Buy", action: onBuy)
                    .buttonStyle(.borderedProminent)
                    .disabled(!canBuy)
            }
            .font(.subheadline)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        )
    }
    
    @ViewBuilder
    private var contentImage: some View {
        switch item {
        case .background(let type):
            Image(type.imageName)
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(16)
        default:
            Image(systemName: item.iconSystemName ?? "bag")
                .resizable()
                .scaledToFit()
                .foregroundColor(.accentColor)
                .padding(16)
        }
    }
}
//
//#Preview("ShopView") {
//    // Provide minimal, placeholder dependencies for preview
//    let previewAnimal = Animal(
//        type: .cat,  // use an AnimalType case, not a string
//        status: .init(
//            happiness: .init(value: 100),
//            health: .init(value: 100),
//            hunger: .init(value: 100)
//        )
//    )
//    let previewShop = Shop()
//    let manager = AnimalManager(animal: previewAnimal, shop: previewShop)
//    NavigationView { ShopView(animalManager: manager) }
//}

