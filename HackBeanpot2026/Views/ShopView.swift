import SwiftUI
import Combine

// ViewModel that bridges the UI to AnimalManager and the Shop catalog
final class ShopViewModel: ObservableObject {
    @Published var selectedCategory: ShopCategory = .upgrades
    @Published private(set) var coins: Int
    
    let animalManager: AnimalManager
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
    
    var allItems: [ShopItem] { shop.items }
    
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
    
    init(animalManager: AnimalManager) {
        _viewModel = StateObject(wrappedValue: ShopViewModel(animalManager: animalManager))
    }
    
    var body: some View {
        ZStack {
            Image("shelves")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            ZStack {
                // Shelves rows overlay across the whole screen
                GeometryReader { proxy in
                    // Adjust these to align rows with the planks in your shelves image
                    let topInset: CGFloat = 40
                    let bottomInset: CGFloat = 70
                    let interShelfSpacing: CGFloat = 8
                    let available = proxy.size.height - topInset - bottomInset - interShelfSpacing * 3
                    let shelfHeight = max(44, available / 4)

                    VStack(spacing: interShelfSpacing) {
                        shelfRow(items: viewModel.allItems.filter { $0.category == .upgrades }, shelfHeight: shelfHeight)
                        shelfRow(items: viewModel.allItems.filter { $0.category == .food }, shelfHeight: shelfHeight)
                        shelfRow(items: viewModel.allItems.filter { $0.category == .accessories }, shelfHeight: shelfHeight)
                        shelfRow(items: viewModel.allItems.filter { $0.category == .backgrounds }, shelfHeight: shelfHeight)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, topInset)
                    .padding(.bottom, bottomInset)
                }

                // Coins header overlay on top
                VStack {
                    HStack {
                        Label("Coins: \(viewModel.coins)", systemImage: "creditcard")
                            .font(.headline)
                            .padding(8)
                            .background(.ultraThinMaterial, in: Capsule())
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    Spacer()
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
    
    @ViewBuilder
    private func shelfRow(items: [ShopItem], shelfHeight: CGFloat) -> some View {
        // Horizontal items scroller over the shelves background
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    let cardWidth = max(100, min(140, shelfHeight * 1.3))
                    ShopItemCard(item: item,
                                 canBuy: viewModel.canBuy(item),
                                 onBuy: {
                                     do {
                                         try viewModel.buy(item)
                                     } catch AnimalManager.PurchaseError.insufficientFunds {
                                         errorMessage = "Not enough coins."
                                     } catch AnimalManager.PurchaseError.invalidUpgrade {
                                         errorMessage = "This upgrade isn't unlocked yet."
                                     } catch {
                                         errorMessage = "Couldn't complete purchase."
                                     }
                                 },
                                 compact: true)
                    .frame(width: cardWidth, height: shelfHeight)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(height: shelfHeight)
    }
}

struct ShopItemCard: View {
    let item: ShopItem
    let canBuy: Bool
    let onBuy: () -> Void
    let compact: Bool

    init(item: ShopItem, canBuy: Bool, onBuy: @escaping () -> Void, compact: Bool = false) {
        self.item = item
        self.canBuy = canBuy
        self.onBuy = onBuy
        self.compact = compact
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 6 : 10) {
            // Image / Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                
                contentImage
            }
            .frame(height: compact ? 50 : 110)
            
            // Title and price
            Text(item.displayName)
                .font(compact ? .caption : .headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            HStack {
                Image(systemName: "creditcard")
                Text("\(item.cost)")
                Spacer()
                Button("Buy", action: onBuy)
                    .buttonStyle(.borderedProminent)
                    .controlSize(compact ? .small : .regular)
                    .disabled(!canBuy)
            }
            .font(compact ? .caption2 : .subheadline)
        }
        .padding(compact ? 6 : 12)
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
                .padding(compact ? 8 : 16)
        default:
            Image(systemName: item.iconSystemName ?? "bag")
                .resizable()
                .scaledToFit()
                .foregroundColor(.accentColor)
                .padding(compact ? 8 : 16)
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

