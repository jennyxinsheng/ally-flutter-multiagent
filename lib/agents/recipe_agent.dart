import '../core/agent_base.dart';
import '../tools/memory_tools.dart';

class RecipeAgent extends AgentBase {
  final String userId;
  
  RecipeAgent({required this.userId});
  
  @override
  String get name => 'recipe_specialist';
  
  @override
  String get description => 'I specialize in kid-friendly recipes, meal planning, and grocery management. I can suggest recipes and help manage your grocery list.';
  
  @override
  List<Tool> get tools => [
    ...MemoryTools.groceryTools(userId),
    _createRecipeSearchTool(),
    _createKidFriendlyRecipesTool(),
    _createMealPlanningTool(),
    _createNutritionTool(),
  ];
  
  Tool _createRecipeSearchTool() => Tool(
    name: 'search_recipes',
    description: 'Search for recipes based on ingredients, dietary restrictions, or preferences',
    parameters: {
      'type': 'object',
      'properties': {
        'ingredients': {'type': 'string', 'description': 'Available ingredients (optional)'},
        'dietary_restrictions': {'type': 'string', 'description': 'Dietary restrictions (optional)'},
        'meal_type': {'type': 'string', 'description': 'Breakfast, lunch, dinner, or snack (optional)'},
        'prep_time': {'type': 'string', 'description': 'Maximum prep time (optional)'}
      },
      'required': []
    },
    handler: _handleRecipeSearch
  );
  
  Tool _createKidFriendlyRecipesTool() => Tool(
    name: 'get_kid_friendly_recipes',
    description: 'Get recipes specifically designed for children',
    parameters: {
      'type': 'object',
      'properties': {
        'age_group': {'type': 'string', 'description': 'Age group: toddler, preschooler, school-age (optional)'},
        'meal_type': {'type': 'string', 'description': 'Breakfast, lunch, dinner, or snack (optional)'},
        'picky_eater': {'type': 'boolean', 'description': 'Whether child is a picky eater (optional)'}
      },
      'required': []
    },
    handler: _handleKidFriendlyRecipes
  );
  
  Tool _createMealPlanningTool() => Tool(
    name: 'create_meal_plan',
    description: 'Create a meal plan for the week',
    parameters: {
      'type': 'object',
      'properties': {
        'days': {'type': 'integer', 'description': 'Number of days to plan (default 7)'},
        'family_size': {'type': 'integer', 'description': 'Number of people (optional)'},
        'dietary_preferences': {'type': 'string', 'description': 'Dietary preferences or restrictions (optional)'}
      },
      'required': []
    },
    handler: _handleMealPlanning
  );
  
  Tool _createNutritionTool() => Tool(
    name: 'get_nutrition_info',
    description: 'Get nutrition information and tips for children',
    parameters: {
      'type': 'object',
      'properties': {
        'topic': {'type': 'string', 'description': 'Nutrition topic (e.g., picky eating, balanced meals, snacks)'},
        'child_age': {'type': 'string', 'description': 'Age of child (optional)'}
      },
      'required': ['topic']
    },
    handler: _handleNutritionInfo
  );
  
  Future<Map<String, dynamic>> _handleRecipeSearch(Map<String, dynamic> args) async {
    final ingredients = args['ingredients'] as String?;
    final mealType = args['meal_type'] as String?;
    
    // Sample recipes - in a real implementation, this would query a recipe database
    final recipes = [
      {
        'name': 'Quick Pasta with Hidden Veggies',
        'prep_time': '15 minutes',
        'ingredients': ['pasta', 'tomato sauce', 'carrots', 'zucchini', 'cheese'],
        'description': 'Kid-friendly pasta with finely chopped vegetables hidden in the sauce',
        'meal_type': 'dinner'
      },
      {
        'name': 'Banana Pancakes',
        'prep_time': '10 minutes',
        'ingredients': ['bananas', 'eggs', 'flour', 'milk'],
        'description': 'Fluffy pancakes with natural sweetness from bananas',
        'meal_type': 'breakfast'
      },
      {
        'name': 'Veggie Quesadillas',
        'prep_time': '12 minutes',
        'ingredients': ['tortillas', 'cheese', 'bell peppers', 'spinach'],
        'description': 'Crispy quesadillas packed with colorful vegetables',
        'meal_type': 'lunch'
      },
      {
        'name': 'Apple Cinnamon Oatmeal',
        'prep_time': '8 minutes',
        'ingredients': ['oats', 'apple', 'cinnamon', 'milk', 'honey'],
        'description': 'Warm, comforting oatmeal with sweet apple pieces',
        'meal_type': 'breakfast'
      },
    ];
    
    // Filter recipes based on criteria
    var filteredRecipes = recipes.where((recipe) {
      if (mealType != null && recipe['meal_type'] != mealType.toLowerCase()) {
        return false;
      }
      
      if (ingredients != null) {
        final recipeIngredients = recipe['ingredients'] as List<String>;
        final searchIngredients = ingredients.toLowerCase().split(',').map((e) => e.trim());
        final hasIngredient = searchIngredients.any((searchIng) =>
            recipeIngredients.any((recipeIng) => recipeIng.toLowerCase().contains(searchIng)));
        if (!hasIngredient) return false;
      }
      
      return true;
    }).toList();
    
    if (filteredRecipes.isEmpty) {
      return {
        'status': 'success',
        'message': 'I couldn\'t find recipes matching your criteria. Would you like me to suggest some general kid-friendly recipes instead?'
      };
    }
    
    final response = StringBuffer();
    response.writeln('Here are some recipes I found:\n');
    
    for (final recipe in filteredRecipes.take(3)) {
      response.writeln('**${recipe['name']}** (${recipe['prep_time']})');
      response.writeln('${recipe['description']}');
      response.writeln('*Ingredients: ${(recipe['ingredients'] as List).join(', ')}*\n');
    }
    
    response.writeln('Would you like the full recipe for any of these, or should I add ingredients to your grocery list?');
    
    return {
      'status': 'success',
      'message': response.toString().trim()
    };
  }
  
  Future<Map<String, dynamic>> _handleKidFriendlyRecipes(Map<String, dynamic> args) async {
    final ageGroup = args['age_group'] as String?;
    final pickyEater = args['picky_eater'] as bool?;
    
    final recipes = <String>[];
    
    if (pickyEater == true) {
      recipes.addAll([
        '**Plain Pasta with Butter** - Simple and familiar',
        '**Cheese Quesadilla** - Crispy and mild',
        '**Chicken Nuggets (homemade)** - Baked, not fried',
        '**Fruit Smoothie** - Hide vegetables in sweet fruit',
        '**Mini Meatballs** - Easy to eat, familiar flavors',
      ]);
    } else {
      recipes.addAll([
        '**Rainbow Veggie Wraps** - Colorful and fun to make',
        '**Sweet Potato Fries** - Naturally sweet and nutritious',
        '**Mini Pizzas** - Let kids choose their own toppings',
        '**Banana Oat Muffins** - Perfect for breakfast or snacks',
        '**Veggie-packed Mac and Cheese** - Comfort food with hidden nutrition',
      ]);
    }
    
    if (ageGroup == 'toddler') {
      recipes.addAll([
        '**Finger Foods Platter** - Soft fruits, cheese cubes, crackers',
        '**Mashed Sweet Potato** - Easy to eat, naturally sweet',
        '**Mini Pancakes** - Perfect size for little hands',
      ]);
    }
    
    final response = StringBuffer();
    response.writeln('Kid-friendly recipe suggestions:\n');
    
    for (final recipe in recipes.take(5)) {
      response.writeln('• $recipe');
    }
    
    response.writeln('\n💡 **Tip**: Involve kids in cooking when possible - they\'re more likely to eat what they help make!');
    response.writeln('\nWould you like a detailed recipe for any of these?');
    
    return {
      'status': 'success',
      'message': response.toString().trim()
    };
  }
  
  Future<Map<String, dynamic>> _handleMealPlanning(Map<String, dynamic> args) async {
    final days = args['days'] as int? ?? 7;
    final familySize = args['family_size'] as int?;
    final dietaryPreferences = args['dietary_preferences'] as String?;
    
    final mealPlan = <String>[];
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    final breakfasts = ['Oatmeal with fruit', 'Scrambled eggs and toast', 'Yogurt parfait', 'Pancakes', 'Smoothie bowl', 'Cereal and fruit', 'French toast'];
    final lunches = ['Grilled cheese and soup', 'Pasta salad', 'Quesadillas', 'Sandwich and fruit', 'Leftover dinner', 'Wraps', 'Mac and cheese'];
    final dinners = ['Baked chicken with vegetables', 'Spaghetti with meat sauce', 'Tacos', 'Stir-fry', 'Pizza night', 'Soup and bread', 'Grilled fish with rice'];
    
    for (int i = 0; i < days && i < 7; i++) {
      mealPlan.add('**${daysOfWeek[i]}**');
      mealPlan.add('• Breakfast: ${breakfasts[i]}');
      mealPlan.add('• Lunch: ${lunches[i]}');
      mealPlan.add('• Dinner: ${dinners[i]}');
      mealPlan.add('');
    }
    
    final response = StringBuffer();
    response.writeln('Here\'s your $days-day meal plan:\n');
    response.writeln(mealPlan.join('\n'));
    
    if (familySize != null) {
      response.writeln('📝 **Note**: This plan is designed for $familySize people. Adjust portions as needed.');
    }
    
    if (dietaryPreferences != null) {
      response.writeln('🥗 **Dietary considerations**: $dietaryPreferences');
    }
    
    response.writeln('\n💡 **Tips**:');
    response.writeln('• Prep ingredients on Sunday');
    response.writeln('• Double recipes for leftovers');
    response.writeln('• Keep backup meals for busy days');
    response.writeln('\nWould you like me to create a grocery list for this meal plan?');
    
    return {
      'status': 'success',
      'message': response.toString().trim()
    };
  }
  
  Future<Map<String, dynamic>> _handleNutritionInfo(Map<String, dynamic> args) async {
    final topic = args['topic'] as String;
    final childAge = args['child_age'] as String?;
    
    final nutritionInfo = {
      'picky eating': {
        'info': 'Picky eating is normal for many children and often a phase.',
        'tips': [
          'Offer new foods multiple times without pressure',
          'Make mealtimes pleasant and stress-free',
          'Be a good role model by eating variety yourself',
          'Involve kids in food preparation',
          'Don\'t use food as reward or punishment',
          'Trust that kids will eat when hungry'
        ]
      },
      'balanced meals': {
        'info': 'A balanced meal includes protein, carbohydrates, healthy fats, and fruits/vegetables.',
        'tips': [
          'Fill half the plate with fruits and vegetables',
          'Include a protein source at each meal',
          'Choose whole grains when possible',
          'Limit processed foods and added sugars',
          'Offer water as the main drink',
          'Make meals colorful and appealing'
        ]
      },
      'snacks': {
        'info': 'Healthy snacks can bridge nutritional gaps and provide energy between meals.',
        'tips': [
          'Combine protein with carbohydrates for lasting energy',
          'Offer fruits and vegetables as first choice',
          'Limit sugary and processed snacks',
          'Time snacks so they don\'t interfere with meals',
          'Let kids help choose and prepare snacks',
          'Keep healthy options easily accessible'
        ]
      }
    };
    
    final topicLower = topic.toLowerCase();
    Map<String, dynamic>? matchedInfo;
    
    for (final entry in nutritionInfo.entries) {
      if (topicLower.contains(entry.key) || entry.key.contains(topicLower)) {
        matchedInfo = entry.value;
        break;
      }
    }
    
    if (matchedInfo == null) {
      return {
        'status': 'success',
        'message': 'I don\'t have specific information about "$topic". I can help with: picky eating, balanced meals, or healthy snacks. What would you like to know about?'
      };
    }
    
    final response = StringBuffer();
    response.writeln('**Nutrition: ${topic.toUpperCase()}**\n');
    response.writeln('${matchedInfo['info']}\n');
    response.writeln('**Tips:**');
    
    for (final tip in matchedInfo['tips'] as List) {
      response.writeln('• $tip');
    }
    
    if (childAge != null) {
      response.writeln('\n**Age consideration**: For $childAge children, remember that appetites and preferences can vary greatly. Focus on offering variety and creating positive food experiences.');
    }
    
    return {
      'status': 'success',
      'message': response.toString().trim()
    };
  }
  
  @override
  Future<String> processMessage(String message, Map<String, dynamic> context) async {
    return 'I\'m the recipe specialist. I can help with kid-friendly recipes, meal planning, nutrition advice, and managing your grocery list. What would you like help with today?';
  }
}
