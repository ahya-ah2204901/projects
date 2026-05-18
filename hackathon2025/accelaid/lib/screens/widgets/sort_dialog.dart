import 'package:flutter/material.dart';

class SortDialog extends StatefulWidget {
  final List<String> categories; 
  final String selectedCategory; 

  const SortDialog({
    Key? key,
    required this.selectedCategory, required this.categories,
  }) : super(key: key);

  @override
  _SortDialogState createState() => _SortDialogState();
}

class _SortDialogState extends State<SortDialog> {
  late String _selectedCategory;
 

  @override
  void initState() {
    super.initState();
   
    _selectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
       title: const Text('Sort by:'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.categories.map((category) {
            return RadioListTile(
              title: Text(category),
              value: category,
              groupValue: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory=category;
                });
              },
              


            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); 
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedCategory); 
          },
          child: const Text('Apply'),
        ),
      ],
    );

}
}