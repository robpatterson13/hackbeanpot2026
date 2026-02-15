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
    @State private var selectedItem: ShopItem? = nil
    
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
                    let topInset: CGFloat = 50
                    let bottomInset: CGFloat = 95
                    let interShelfSpacing: CGFloat = 8
                    let available = proxy.size.height - topInset - bottomInset - interShelfSpacing * 3
                    let shelfHeight = max(36, available / 4)

                    VStack(spacing: interShelfSpacing) {
                        shelfRow(category: .upgrades, items: viewModel.allItems.filter { $0.category == .upgrades }, shelfHeight: shelfHeight)
                            .offset(y: verticalOffset(for: .upgrades, shelfHeight: shelfHeight))
                        shelfRow(category: .accessories, items: viewModel.allItems.filter { $0.category == .accessories }, shelfHeight: shelfHeight)
                            .offset(y: verticalOffset(for: .accessories, shelfHeight: shelfHeight))
                        shelfRow(category: .food, items: viewModel.allItems.filter { $0.category == .food }, shelfHeight: shelfHeight)
                            .offset(y: verticalOffset(for: .food, shelfHeight: shelfHeight))
                        shelfRow(category: .backgrounds, items: viewModel.allItems.filter { $0.category == .backgrounds }, shelfHeight: shelfHeight)
                            .offset(y: verticalOffset(for: .backgrounds, shelfHeight: shelfHeight))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, topInset)
                    .padding(.bottom, bottomInset)
                }

                // Coins header overlay on top
                VStack {
                    HStack {
                        Spacer()
                        HStack(spacing: 6) {
                            Image("coin") // replace with your asset name if different
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                            Text("Coins: \(viewModel.coins)")
                                .font(.headline)
                        }
                        .padding(8)
                        .background(.ultraThinMaterial, in: Capsule())
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
        .sheet(isPresented: Binding(get: { selectedItem != nil }, set: { if !$0 { selectedItem = nil } })) {
            if let item = selectedItem {
                ShopItemDetailSheet(item: item,
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
                                    onClose: { selectedItem = nil })
            }
        }
    }
    
    @ViewBuilder
    private func shelfRow(category: ShopCategory, items: [ShopItem], shelfHeight: CGFloat) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: tileSpacing(for: category)) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    let sizing = tileSizing(for: category)
                    let base = shelfHeight * sizing.scale
                    let tileSize = max(sizing.min, min(sizing.max, base))
                    Button {
                        selectedItem = item
                    } label: {
                        thumbnailSquare(for: item, size: tileSize)
                            .frame(width: tileSize, height: tileSize)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(height: shelfHeight)
    }
    
    /// Controls per-category thumbnail sizing on each shelf.
    /// - scale: Proportion of the shelf row height used for this category.
    /// - min/max: Clamps the resulting size across devices. Increase `scale` or `max` to make a category larger.
    private func tileSizing(for category: ShopCategory) -> (scale: CGFloat, min: CGFloat, max: CGFloat) {
        // Adjust these values to tune each category's thumbnail size
        switch category {
        case .upgrades:
            // Pets slightly larger
            return (scale: 0.80, min: 68, max: 120)
        case .accessories:
            return (scale: 0.70, min: 56, max: 120)
        case .food:
            return (scale: 0.60, min: 52, max: 120)
        case .backgrounds:
            // Backgrounds slightly smaller
            return (scale: 0.50, min: 40, max: 70)
        }
    }
    
    /// Per-category horizontal spacing between thumbnails.
    /// Increase spacing for categories that feel too tight (e.g., backgrounds).
    private func tileSpacing(for category: ShopCategory) -> CGFloat {
        switch category {
        case .backgrounds:
            return 60 // more breathing room for backgrounds
        case .upgrades, .accessories, .food:
            return 8
        }
    }
    
    /// Per-category vertical adjustment to fine-tune alignment with shelf planks.
    /// Negative values move a row up; positive values move it down.
    /// Tip: Start small (e.g., -0.08) and adjust.
    private func verticalOffset(for category: ShopCategory, shelfHeight: CGFloat) -> CGFloat {
        switch category {
        case .upgrades:
            return -shelfHeight * 0.15 // move pets up a bit more
        case .accessories:
            return -shelfHeight * 0.08 // middle rows up slightly
        case .food:
            return -shelfHeight * 0.08 // middle rows up slightly
        case .backgrounds:
            return 0 // align backgrounds with others
        }
    }
    
    @ViewBuilder
    private func thumbnailSquare(for item: ShopItem, size: CGFloat) -> some View {
        ZStack {
            if case .background = item, let name = shopAssetName(for: item) {
                Image(name)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.9), lineWidth: 1))
            } else if let name = shopAssetName(for: item) {
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.9, height: size * 0.9)
            } else {
                Image(systemName: item.iconSystemName ?? "bag")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.8, height: size * 0.8)
                    .foregroundColor(.accentColor)
            }
        }
    }
}

fileprivate func shopAssetName(for item: ShopItem) -> String? {
    switch item {
    case .steak: return "steak"
    case .fedora: return "fedora"
    case .sunglasses: return "sunglasses"
    case .tie: return "tie"
    case .bowtie: return "bowtie"
    case .potion: return "potion"
    case .pills: return "pills"
    case .background(let type): return type.imageName
    case .upgrade(let upgrade):
        switch upgrade {
        case .fish: return "fish_state_1"
        case .gecko: return "gecko_state_1"
        case .cat: return "cat_state_1"
        case .dog: return "dog_state_1"
        case .unicorn: return "unicorn_state_1"
        }
    }
}

struct ShopItemCard: View {
    let item: ShopItem
    let canBuy: Bool
    let onBuy: () -> Void
    let compact: Bool
    let imageHeight: CGFloat?

    init(item: ShopItem, canBuy: Bool, onBuy: @escaping () -> Void, compact: Bool = false, imageHeight: CGFloat? = nil) {
        self.item = item
        self.canBuy = canBuy
        self.onBuy = onBuy
        self.compact = compact
        self.imageHeight = imageHeight
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 6 : 10) {
            // Image / Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                
                contentImage
                    .offset(y: compact ? -2 : -6)
            }
            .frame(height: imageHeight ?? (compact ? 50 : 90))
            
            // Title and price
            Text(item.displayName)
                .font(compact ? .caption : .headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            HStack {
                Image("coin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
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
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(compact ? 6 : 20)
        default:
            if let assetName = shopAssetName(for: item) {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .padding(compact ? 8 : 20)
            } else {
                Image(systemName: item.iconSystemName ?? "bag")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.accentColor)
                    .padding(compact ? 8 : 16)
            }
        }
    }
}

struct ShopItemDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let item: ShopItem
    let canBuy: Bool
    let onBuy: () -> Void
    let onClose: () -> Void

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ScrollView {
                    ShopItemCard(item: item, canBuy: canBuy, onBuy: onBuy, compact: false, imageHeight: max(200, geo.size.height * 0.45))
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .navigationTitle(item.displayName)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        onClose()
                        dismiss()
                    }
                }
            }
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

