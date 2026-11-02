import Foundation

private func i(_ name: String, _ qty: Double, _ unit: MeasureUnit, _ aisle: Aisle, search: String? = nil) -> Ingredient {
    Ingredient(name: name, quantity: qty, unit: unit, aisle: aisle, searchTerm: search)
}

/// The built-in starter library. Ingredient names are deliberately shared across
/// meals ("yellow onion", "garlic", "shredded cheddar") so the list engine can merge them.
enum MealLibrary {
    static let all: [Meal] = [
        Meal(
            id: "chicken-fajitas", name: "Sheet-Pan Chicken Fajitas", emoji: "🌯",
            summary: "Peppers, onions and spiced chicken roasted on one pan.",
            minutes: 30, servings: 4, tags: ["Quick", "Family"],
            ingredients: [
                i("chicken breast", 1.5, .lb, .meat, search: "boneless skinless chicken breast"),
                i("bell pepper", 3, .each, .produce),
                i("yellow onion", 1, .each, .produce),
                i("flour tortillas", 1, .package, .bakery),
                i("olive oil", 2, .tbsp, .spices),
                i("chili powder", 2, .tsp, .spices),
                i("ground cumin", 1, .tsp, .spices),
                i("lime", 1, .each, .produce),
                i("sour cream", 0.5, .cup, .dairy),
                i("salt", 1, .tsp, .spices),
            ],
            steps: [
                "Heat oven to 425°F.",
                "Slice chicken, peppers and onion into strips. Toss with oil, chili powder, cumin and salt.",
                "Spread on a sheet pan and roast 20–25 minutes.",
                "Squeeze lime over the top and serve in warm tortillas with sour cream.",
            ]
        ),
        Meal(
            id: "spaghetti-bolognese", name: "Spaghetti Bolognese", emoji: "🍝",
            summary: "A weeknight meat sauce that tastes like it simmered all day.",
            minutes: 40, servings: 4, tags: ["Family", "Kid-friendly"],
            ingredients: [
                i("ground beef", 1, .lb, .meat),
                i("spaghetti", 1, .lb, .pantry),
                i("crushed tomatoes", 1, .can, .pantry, search: "crushed tomatoes 28 oz"),
                i("yellow onion", 1, .each, .produce),
                i("garlic", 3, .clove, .produce),
                i("carrot", 1, .each, .produce, search: "carrots"),
                i("olive oil", 1, .tbsp, .spices),
                i("parmesan", 0.5, .cup, .dairy, search: "grated parmesan cheese"),
                i("italian seasoning", 1, .tsp, .spices),
                i("salt", 1, .tsp, .spices),
            ],
            steps: [
                "Finely chop onion, carrot and garlic. Soften in olive oil, 5 minutes.",
                "Add beef and brown, breaking it up.",
                "Stir in tomatoes, Italian seasoning and salt. Simmer 20 minutes.",
                "Cook spaghetti, toss with sauce and top with parmesan.",
            ]
        ),
        Meal(
            id: "beef-tacos", name: "Beef Tacos", emoji: "🌮",
            summary: "Crunchy shells, seasoned beef and all the toppings.",
            minutes: 20, servings: 4, tags: ["Quick", "Kid-friendly"],
            ingredients: [
                i("ground beef", 1, .lb, .meat),
                i("taco shells", 1, .package, .pantry),
                i("taco seasoning", 1, .package, .spices),
                i("shredded cheddar", 1, .cup, .dairy, search: "shredded cheddar cheese"),
                i("romaine lettuce", 1, .each, .produce),
                i("tomato", 2, .each, .produce, search: "tomatoes"),
                i("sour cream", 0.5, .cup, .dairy),
                i("salsa", 1, .cup, .pantry),
            ],
            steps: [
                "Brown the beef, drain, then add taco seasoning and water per the packet.",
                "Warm the shells in the oven for 5 minutes.",
                "Shred lettuce and dice tomatoes.",
                "Fill shells and top with cheese, sour cream and salsa.",
            ]
        ),
        Meal(
            id: "chicken-stir-fry", name: "Chicken Stir-Fry with Rice", emoji: "🥡",
            summary: "Honey-soy chicken and broccoli over jasmine rice.",
            minutes: 30, servings: 4, tags: ["Quick", "Healthy"],
            ingredients: [
                i("chicken breast", 1, .lb, .meat, search: "boneless skinless chicken breast"),
                i("broccoli", 1, .lb, .produce, search: "broccoli crowns"),
                i("bell pepper", 1, .each, .produce),
                i("garlic", 2, .clove, .produce),
                i("fresh ginger", 1, .tbsp, .produce, search: "ginger root"),
                i("soy sauce", 3, .tbsp, .spices),
                i("honey", 1, .tbsp, .pantry),
                i("cornstarch", 1, .tbsp, .pantry),
                i("jasmine rice", 1.5, .cup, .pantry),
                i("vegetable oil", 1, .tbsp, .spices),
            ],
            steps: [
                "Start the rice.",
                "Whisk soy sauce, honey, cornstarch and 1/4 cup water.",
                "Stir-fry sliced chicken in oil until cooked; set aside.",
                "Stir-fry broccoli, pepper, garlic and ginger 4 minutes. Return chicken, add sauce, toss until glossy.",
            ]
        ),
        Meal(
            id: "turkey-chili", name: "Turkey Chili", emoji: "🌶️",
            summary: "Hearty, lean and even better as leftovers.",
            minutes: 45, servings: 6, tags: ["Healthy", "Leftovers"],
            ingredients: [
                i("ground turkey", 1, .lb, .meat),
                i("kidney beans", 2, .can, .pantry),
                i("diced tomatoes", 1, .can, .pantry),
                i("yellow onion", 1, .each, .produce),
                i("bell pepper", 1, .each, .produce),
                i("garlic", 2, .clove, .produce),
                i("chili powder", 2, .tbsp, .spices),
                i("ground cumin", 1, .tsp, .spices),
                i("chicken broth", 1, .cup, .pantry),
                i("shredded cheddar", 0.5, .cup, .dairy, search: "shredded cheddar cheese"),
            ],
            steps: [
                "Cook onion, pepper and garlic until soft.",
                "Add turkey and brown.",
                "Add spices, beans (drained), tomatoes and broth. Simmer 25 minutes.",
                "Serve topped with cheddar.",
            ]
        ),
        Meal(
            id: "lemon-garlic-salmon", name: "Lemon Garlic Salmon", emoji: "🐟",
            summary: "Buttery salmon with roasted asparagus on one pan.",
            minutes: 25, servings: 4, tags: ["Quick", "Healthy"],
            ingredients: [
                i("salmon fillets", 1.5, .lb, .meat),
                i("lemon", 1, .each, .produce),
                i("garlic", 3, .clove, .produce),
                i("butter", 2, .tbsp, .dairy),
                i("asparagus", 1, .bunch, .produce),
                i("olive oil", 1, .tbsp, .spices),
                i("salt", 1, .tsp, .spices),
                i("black pepper", 0.5, .tsp, .spices),
            ],
            steps: [
                "Heat oven to 400°F.",
                "Toss asparagus with oil, salt and pepper; arrange around salmon on a sheet pan.",
                "Melt butter with minced garlic and lemon juice; spoon over salmon.",
                "Roast 12–15 minutes.",
            ]
        ),
        Meal(
            id: "black-bean-quesadillas", name: "Black Bean Quesadillas", emoji: "🧀",
            summary: "Cheesy, crispy and meatless in 15 minutes.",
            minutes: 15, servings: 4, tags: ["Quick", "Vegetarian", "Kid-friendly"],
            ingredients: [
                i("flour tortillas", 1, .package, .bakery),
                i("black beans", 1, .can, .pantry),
                i("shredded cheddar", 2, .cup, .dairy, search: "shredded cheddar cheese"),
                i("frozen corn", 1, .cup, .frozen),
                i("salsa", 0.5, .cup, .pantry),
                i("sour cream", 0.5, .cup, .dairy),
                i("ground cumin", 0.5, .tsp, .spices),
            ],
            steps: [
                "Mash half the drained beans with cumin; stir in the rest plus corn.",
                "Spread on half of each tortilla, top with cheese and fold.",
                "Cook in a dry skillet 2–3 minutes per side.",
                "Cut into wedges and serve with salsa and sour cream.",
            ]
        ),
        Meal(
            id: "chicken-caesar-wraps", name: "Chicken Caesar Wraps", emoji: "🥗",
            summary: "Crisp romaine, chicken and parmesan rolled up tight.",
            minutes: 20, servings: 4, tags: ["Quick"],
            ingredients: [
                i("chicken breast", 1, .lb, .meat, search: "boneless skinless chicken breast"),
                i("romaine lettuce", 1, .each, .produce),
                i("flour tortillas", 1, .package, .bakery),
                i("caesar dressing", 0.5, .cup, .spices),
                i("parmesan", 0.25, .cup, .dairy, search: "grated parmesan cheese"),
                i("olive oil", 1, .tbsp, .spices),
                i("salt", 0.5, .tsp, .spices),
            ],
            steps: [
                "Season chicken with salt and cook in olive oil, 6 minutes per side. Slice.",
                "Chop romaine and toss with dressing and parmesan.",
                "Fill tortillas with salad and chicken, roll and halve.",
            ]
        ),
        Meal(
            id: "veggie-fried-rice", name: "Veggie Fried Rice", emoji: "🍳",
            summary: "The best use of leftover rice, loaded with egg and veg.",
            minutes: 20, servings: 4, tags: ["Quick", "Vegetarian"],
            ingredients: [
                i("jasmine rice", 1.5, .cup, .pantry),
                i("eggs", 3, .each, .dairy),
                i("frozen peas and carrots", 2, .cup, .frozen),
                i("green onions", 1, .bunch, .produce),
                i("soy sauce", 3, .tbsp, .spices),
                i("garlic", 2, .clove, .produce),
                i("vegetable oil", 2, .tbsp, .spices),
                i("sesame oil", 1, .tsp, .spices),
            ],
            steps: [
                "Cook rice ahead and chill (or use leftovers).",
                "Scramble eggs in a little oil; set aside.",
                "Fry garlic and peas and carrots, then add rice and fry until hot.",
                "Add soy sauce, sesame oil, eggs and sliced green onions.",
            ]
        ),
        Meal(
            id: "baked-ziti", name: "Baked Ziti", emoji: "🍝",
            summary: "Bubbly, cheesy pasta bake that feeds a crowd.",
            minutes: 45, servings: 6, tags: ["Vegetarian", "Family", "Leftovers"],
            ingredients: [
                i("ziti", 1, .lb, .pantry, search: "ziti pasta"),
                i("marinara sauce", 1, .jar, .pantry),
                i("ricotta", 15, .oz, .dairy, search: "ricotta cheese"),
                i("shredded mozzarella", 2, .cup, .dairy, search: "shredded mozzarella cheese"),
                i("parmesan", 0.5, .cup, .dairy, search: "grated parmesan cheese"),
                i("italian seasoning", 1, .tsp, .spices),
            ],
            steps: [
                "Heat oven to 375°F. Boil ziti 2 minutes short of package time.",
                "Mix pasta with marinara, ricotta and Italian seasoning.",
                "Spread in a baking dish, top with mozzarella and parmesan.",
                "Bake 25 minutes until bubbling.",
            ]
        ),
        Meal(
            id: "honey-garlic-pork-chops", name: "Honey Garlic Pork Chops", emoji: "🍖",
            summary: "Sticky-sweet glazed chops with green beans.",
            minutes: 30, servings: 4, tags: ["Family"],
            ingredients: [
                i("pork chops", 1.5, .lb, .meat, search: "boneless pork chops"),
                i("honey", 3, .tbsp, .pantry),
                i("soy sauce", 2, .tbsp, .spices),
                i("garlic", 4, .clove, .produce),
                i("butter", 1, .tbsp, .dairy),
                i("green beans", 1, .lb, .produce),
                i("olive oil", 1, .tbsp, .spices),
            ],
            steps: [
                "Sear chops in oil 4–5 minutes per side; remove.",
                "Melt butter, add garlic, then honey and soy sauce. Simmer 1 minute.",
                "Return chops and spoon glaze over.",
                "Steam or sauté green beans to serve alongside.",
            ]
        ),
        Meal(
            id: "chicken-noodle-soup", name: "Chicken Noodle Soup", emoji: "🍲",
            summary: "Cozy classic with thighs, egg noodles and lots of veg.",
            minutes: 45, servings: 6, tags: ["Family", "Leftovers"],
            ingredients: [
                i("chicken thighs", 1, .lb, .meat, search: "boneless skinless chicken thighs"),
                i("egg noodles", 8, .oz, .pantry),
                i("chicken broth", 8, .cup, .pantry),
                i("carrot", 2, .each, .produce, search: "carrots"),
                i("celery", 1, .bunch, .produce),
                i("yellow onion", 1, .each, .produce),
                i("garlic", 2, .clove, .produce),
                i("dried thyme", 1, .tsp, .spices),
                i("butter", 2, .tbsp, .dairy),
            ],
            steps: [
                "Soften chopped onion, carrot, celery (3 stalks) and garlic in butter.",
                "Add broth, thyme and whole chicken thighs. Simmer 20 minutes.",
                "Shred chicken, return to pot with noodles; cook 7 minutes.",
            ]
        ),
        Meal(
            id: "cheeseburgers-fries", name: "Cheeseburgers & Oven Fries", emoji: "🍔",
            summary: "Diner night at home without the fryer.",
            minutes: 40, servings: 4, tags: ["Kid-friendly", "Family"],
            ingredients: [
                i("ground beef", 1.5, .lb, .meat),
                i("hamburger buns", 1, .package, .bakery),
                i("sliced cheddar", 4, .slice, .dairy, search: "sliced cheddar cheese"),
                i("russet potatoes", 2, .lb, .produce),
                i("tomato", 1, .each, .produce, search: "tomatoes"),
                i("red onion", 1, .each, .produce),
                i("olive oil", 2, .tbsp, .spices),
                i("salt", 1, .tsp, .spices),
            ],
            steps: [
                "Heat oven to 425°F. Cut potatoes into wedges, toss with oil and salt, roast 30 minutes.",
                "Form beef into 4 patties, season and grill or pan-sear 4 minutes per side.",
                "Add cheese for the last minute.",
                "Serve on buns with sliced tomato and onion.",
            ]
        ),
        Meal(
            id: "shrimp-scampi", name: "Shrimp Scampi Pasta", emoji: "🍤",
            summary: "Garlicky, lemony shrimp tossed with linguine.",
            minutes: 25, servings: 4, tags: ["Quick"],
            ingredients: [
                i("shrimp", 1, .lb, .meat, search: "raw shrimp peeled deveined"),
                i("linguine", 1, .lb, .pantry),
                i("garlic", 4, .clove, .produce),
                i("butter", 4, .tbsp, .dairy),
                i("lemon", 1, .each, .produce),
                i("parmesan", 0.25, .cup, .dairy, search: "grated parmesan cheese"),
                i("red pepper flakes", 0.5, .tsp, .spices),
                i("fresh parsley", 1, .bunch, .produce),
            ],
            steps: [
                "Cook linguine; save 1/2 cup pasta water.",
                "Melt butter, add garlic and pepper flakes, then shrimp. Cook 3 minutes.",
                "Add lemon juice, pasta and a splash of pasta water; toss.",
                "Finish with parsley and parmesan.",
            ]
        ),
        Meal(
            id: "breakfast-egg-bake", name: "Breakfast-for-Dinner Egg Bake", emoji: "🥚",
            summary: "Sausage, hash browns and cheese baked into one pan.",
            minutes: 50, servings: 6, tags: ["Family", "Leftovers"],
            ingredients: [
                i("eggs", 10, .each, .dairy),
                i("milk", 1, .cup, .dairy),
                i("breakfast sausage", 1, .lb, .meat),
                i("shredded cheddar", 1, .cup, .dairy, search: "shredded cheddar cheese"),
                i("bell pepper", 1, .each, .produce),
                i("frozen hash browns", 1, .package, .frozen, search: "frozen shredded hash browns"),
                i("green onions", 1, .bunch, .produce),
            ],
            steps: [
                "Heat oven to 350°F. Brown sausage with diced pepper.",
                "Spread hash browns in a greased 9x13 dish; top with sausage mixture and cheese.",
                "Whisk eggs and milk, pour over.",
                "Bake 40 minutes; top with green onions.",
            ]
        ),
    ]

    static func meal(id: String) -> Meal? { all.first { $0.id == id } }

    static var allTags: [String] {
        Array(Set(all.flatMap(\.tags))).sorted()
    }
}
