import '../core/agent_base.dart';
import '../services/memory_manager.dart';

class MemoryTools {
  static final MemoryManager _memoryManager = MemoryManager();
  
  static Tool storeReminder(String userId) => Tool(
    name: 'store_reminder',
    description: 'Store a reminder for the user',
    parameters: {
      'type': 'object',
      'properties': {
        'reminder': {'type': 'string', 'description': 'The reminder text'}
      },
      'required': ['reminder']
    },
    handler: (args) async {
      await _memoryManager.addAdminItem(userId, 'reminders', args['reminder'] as String);
      return {'status': 'success', 'message': 'got it'};
    }
  );
  
  static Tool storeEvent(String userId) => Tool(
    name: 'store_event',
    description: 'Store an event for the user',
    parameters: {
      'type': 'object',
      'properties': {
        'event': {'type': 'string', 'description': 'The event text'}
      },
      'required': ['event']
    },
    handler: (args) async {
      await _memoryManager.addAdminItem(userId, 'events', args['event'] as String);
      return {'status': 'success', 'message': 'got it'};
    }
  );
  
  static Tool storeGrocery(String userId) => Tool(
    name: 'store_grocery',
    description: 'Store a grocery item for the user',
    parameters: {
      'type': 'object',
      'properties': {
        'item': {'type': 'string', 'description': 'The grocery item'}
      },
      'required': ['item']
    },
    handler: (args) async {
      await _memoryManager.addAdminItem(userId, 'groceries', args['item'] as String);
      return {'status': 'success', 'message': 'got it'};
    }
  );
  
  static Tool storeListItem(String userId) => Tool(
    name: 'store_list_item',
    description: 'Store an item in a custom list',
    parameters: {
      'type': 'object',
      'properties': {
        'list_name': {'type': 'string', 'description': 'The name of the list'},
        'item': {'type': 'string', 'description': 'The item to add'}
      },
      'required': ['list_name', 'item']
    },
    handler: (args) async {
      await _memoryManager.addAdminItem(
        userId, 
        'other_lists', 
        args['item'] as String, 
        listName: args['list_name'] as String
      );
      return {'status': 'success', 'message': 'got it'};
    }
  );
  
  static Tool getReminders(String userId) => Tool(
    name: 'get_reminders',
    description: 'Get all reminders for the user',
    parameters: {
      'type': 'object',
      'properties': {},
      'required': []
    },
    handler: (args) async {
      final items = await _memoryManager.getAdminItems(userId, 'reminders');
      if (items.isEmpty) {
        return {'status': 'success', 'message': 'No reminders stored'};
      }
      
      final reminderList = items.map((item) => '- ${item['item']}').join('\n');
      return {'status': 'success', 'message': 'Your reminders:\n$reminderList'};
    }
  );
  
  static Tool getEvents(String userId) => Tool(
    name: 'get_events',
    description: 'Get all events for the user',
    parameters: {
      'type': 'object',
      'properties': {},
      'required': []
    },
    handler: (args) async {
      final items = await _memoryManager.getAdminItems(userId, 'events');
      if (items.isEmpty) {
        return {'status': 'success', 'message': 'No events stored'};
      }
      
      final eventList = items.map((item) => '- ${item['item']}').join('\n');
      return {'status': 'success', 'message': 'Your events:\n$eventList'};
    }
  );
  
  static Tool getGroceries(String userId) => Tool(
    name: 'get_groceries',
    description: 'Get grocery list organized by supermarket sections',
    parameters: {
      'type': 'object',
      'properties': {},
      'required': []
    },
    handler: (args) async {
      final items = await _memoryManager.getAdminItems(userId, 'groceries');
      if (items.isEmpty) {
        return {'status': 'success', 'message': 'No groceries on your list'};
      }
      
      final groceryList = items.map((item) => '- ${item['item']}').join('\n');
      return {'status': 'success', 'message': 'Your grocery list:\n$groceryList'};
    }
  );
  
  static Tool getList(String userId) => Tool(
    name: 'get_list',
    description: 'Get a custom list for the user',
    parameters: {
      'type': 'object',
      'properties': {
        'list_name': {'type': 'string', 'description': 'The name of the list'}
      },
      'required': ['list_name']
    },
    handler: (args) async {
      final listName = args['list_name'] as String;
      final items = await _memoryManager.getAdminItems(userId, 'other_lists', listName: listName);
      if (items.isEmpty) {
        return {'status': 'success', 'message': 'No items in $listName list'};
      }
      
      final itemList = items.map((item) => '- ${item['item']}').join('\n');
      return {'status': 'success', 'message': '$listName list:\n$itemList'};
    }
  );
  
  static Tool getAllLists(String userId) => Tool(
    name: 'get_all_lists',
    description: 'Get all admin lists for the user',
    parameters: {
      'type': 'object',
      'properties': {},
      'required': []
    },
    handler: (args) async {
      final adminData = await _memoryManager.getAllAdminData(userId);
      final result = <String>[];
      
      if ((adminData['reminders'] as List).isNotEmpty) {
        result.add('Reminders (${(adminData['reminders'] as List).length} items)');
      }
      
      if ((adminData['events'] as List).isNotEmpty) {
        result.add('Events (${(adminData['events'] as List).length} items)');
      }
      
      if ((adminData['groceries'] as List).isNotEmpty) {
        result.add('Groceries (${(adminData['groceries'] as List).length} items)');
      }
      
      final otherLists = adminData['other_lists'] as Map<String, dynamic>;
      for (final entry in otherLists.entries) {
        final items = entry.value as List;
        if (items.isNotEmpty) {
          result.add('${entry.key} (${items.length} items)');
        }
      }
      
      if (result.isEmpty) {
        return {'status': 'success', 'message': 'No lists stored yet'};
      }
      
      final listSummary = result.map((item) => '- $item').join('\n');
      return {'status': 'success', 'message': 'Your lists:\n$listSummary'};
    }
  );
  
  static Tool removeItem(String userId) => Tool(
    name: 'remove_item',
    description: 'Remove an item from a list',
    parameters: {
      'type': 'object',
      'properties': {
        'subcategory': {'type': 'string', 'description': 'The subcategory (reminders, events, groceries, other_lists)'},
        'item': {'type': 'string', 'description': 'The item to remove'},
        'list_name': {'type': 'string', 'description': 'The list name (for other_lists only)'}
      },
      'required': ['subcategory', 'item']
    },
    handler: (args) async {
      final success = await _memoryManager.removeAdminItem(
        userId,
        args['subcategory'] as String,
        args['item'] as String,
        listName: args['list_name'] as String?
      );
      
      if (success) {
        return {'status': 'success', 'message': 'Removed \'${args['item']}\' from ${args['subcategory']}'};
      } else {
        return {'status': 'error', 'message': 'Could not find \'${args['item']}\' in ${args['subcategory']}'};
      }
    }
  );
  
  static Tool clearList(String userId) => Tool(
    name: 'clear_list',
    description: 'Clear all items from a list',
    parameters: {
      'type': 'object',
      'properties': {
        'subcategory': {'type': 'string', 'description': 'The subcategory to clear'},
        'list_name': {'type': 'string', 'description': 'The list name (for other_lists only)'}
      },
      'required': ['subcategory']
    },
    handler: (args) async {
      final success = await _memoryManager.clearAdminSubcategory(
        userId,
        args['subcategory'] as String,
        listName: args['list_name'] as String?
      );
      
      if (success) {
        return {'status': 'success', 'message': 'Cleared ${args['subcategory']}'};
      } else {
        return {'status': 'error', 'message': 'Could not clear ${args['subcategory']}'};
      }
    }
  );
  
  static List<Tool> allTools(String userId) => [
    storeReminder(userId),
    storeEvent(userId),
    storeGrocery(userId),
    storeListItem(userId),
    getReminders(userId),
    getEvents(userId),
    getGroceries(userId),
    getList(userId),
    getAllLists(userId),
    removeItem(userId),
    clearList(userId),
  ];
  
  static List<Tool> groceryTools(String userId) => [
    storeGrocery(userId),
    getGroceries(userId),
    removeItem(userId),
    clearList(userId),
  ];
}
