
import 'dart:typed_data';
import 'package:attendance_system_admin/core/app_colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BaseRightDrawer extends StatefulWidget{
  const BaseRightDrawer({super.key});
  @override
  State<BaseRightDrawer> createState() => _RightDrawerWidgetState();
}

class _RightDrawerWidgetState extends State<BaseRightDrawer> {
   
  @override

  Widget build(BuildContext context){
    return Drawer(
        width: 450,
        elevation: 10,
        backgroundColor: Color.fromRGBO(251, 249, 249, 1),
        shape: Border.all(
          style: BorderStyle.solid,
          color: Color.fromRGBO(255, 251, 251, 1)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
            DrawerTitleWidget(),

            SizedBox(height: 10,),

            PhotoPickerWidget(),

            SizedBox(height: 10,),

            MemberNameFieldWidget(),

            SizedBox(height: 15),

            EmailFieldWidget(),
            
            SizedBox(height: 15,),
            
            DropDownWidget(),

            SizedBox(height: 40,),

            NoteWidget(),

            Spacer(),
            
            ConcludeButtonWidget()
      ],
          ),
        ),
      );
  }
}


class DrawerTitleWidget extends StatelessWidget{
  const DrawerTitleWidget({super.key});
  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
            children: [
            Text("Add User",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,)),
            Spacer(),
            IconButton(
            onPressed: (){Navigator.pop(context);},
            icon: Icon(Icons.close,
            fontWeight: FontWeight.bold,
            color: Colors.black,))
            ],
            ),
          Text("Invite a new member to your team", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,))
      ],
    );
              
  }
}

class PhotoPickerWidget extends StatefulWidget{
  const PhotoPickerWidget({super.key});
  @override
  State<PhotoPickerWidget> createState() => _PhotoPickerWidgetState();
}

class _PhotoPickerWidgetState extends State<PhotoPickerWidget> {
  Uint8List? selectedImage;

Future<void> pickImage() async {
  FilePickerResult? result = await FilePicker.pickFiles(
    type: FileType.image,
    allowMultiple: false,
    withData: true, // Needed for web
  );

  if (result != null) {
    selectedImage = result.files.first.bytes;
  }
}
  @override
  Widget build(BuildContext context){
    return DottedBorder(
              options: RoundedRectDottedBorderOptions(
              radius: Radius.circular(10),
              color: Color.fromRGBO(180, 244, 235, 1),
              strokeWidth: 2,
              dashPattern: [2,2]
            ),
                child: InkWell(
                  onTap:() {
                   pickImage();
                  },
                  child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                        shape: BoxShape.circle, 
                        border: Border.all(color: Colors.grey.shade300, width: 2)),
                        child: Icon(Icons.upload_file),
                      ),
                  
                      Text("Click to upload photo",
                      style: TextStyle(fontWeight: FontWeight.w700),),
                      Text("JPG or PNG (max 2MB)",
                      style: TextStyle(fontSize: 12),)
                    ],
                  ),
                  ),
                  ),
                ));
  }
}

class MemberNameFieldWidget extends StatelessWidget{
  const MemberNameFieldWidget({super.key});
  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
           Text("MEMBER NAME", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromRGBO(91, 90, 90, 1)),),
            SizedBox(height: 8,),
            TextField(
             decoration: InputDecoration(
             contentPadding: EdgeInsets.all(10),
             hintStyle: GoogleFonts.quicksand(
            fontWeight: FontWeight.w500,
            color: const Color.fromARGB(207, 127, 152, 187),
            fontSize: 15
          ),
          hintText: "John Doe",
          filled: true,
          fillColor: AppColors.lightScaffoldColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1.5,
              color: const Color.fromRGBO(177, 197, 225, 1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1.5,
              color: const Color.fromARGB(255, 177, 197, 225),
            ),
          ),
        ),
      ),
      ],
    );
  }
}

class EmailFieldWidget extends StatelessWidget{
  const EmailFieldWidget({super.key});
  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("EMAIL ADDRESS", style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(91, 90, 90, 1)),),

      SizedBox(height: 8,),

      TextField(
             decoration: InputDecoration(
             contentPadding: EdgeInsets.all(10),
             hintStyle: GoogleFonts.quicksand(
            fontWeight: FontWeight.w500,
            color: const Color.fromARGB(207, 127, 152, 187),
            fontSize: 15
          ),
          hintText: "John@example.com",
          filled: true,
          fillColor: AppColors.lightScaffoldColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1.5,
              color: const Color.fromARGB(255, 177, 197, 225),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1.5,
              color: const Color.fromARGB(255, 177, 197, 225),
            ),
          ),
        ),
      ),
      ],
    );
  }
}

class DropDownWidget extends StatefulWidget{
  const DropDownWidget({super.key});

  @override
  State<DropDownWidget> createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget> {
  String? _department;
   String? _role;
  @override
  Widget build(BuildContext context){
    return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("DEPARTMENT", style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(91, 90, 90, 1)),
                ),
                SizedBox(height: 8,),

                CustomDropdown<String>(
              hintText: 'Choose one',
              items: ['Engineering', 'Folk', 'Uhhhhh'],
              value: _department,
              itemAsString: (dept) => dept, // Simply returns the string itself
              onChanged: (value) {
                setState(() {
                  _department = value;
                });
              },
            )
                ],
            ),
          ),
         
          SizedBox(width: 30,),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ACCESS ROLE", style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(91, 90, 90, 1)),
                ),
                SizedBox(height: 8,),

                CustomDropdown<String>(
              hintText: 'Choose one',
              items: ['Staff', 'Manager', 'Idk'],
              value: _role,
              itemAsString: (role) => role, // Simply returns the string itself
              onChanged: (value) {
                setState(() {
                  _role = value;
                });
              },
            )
              ],
            ),
          )
        ],
      );
  }
}

class NoteWidget extends StatelessWidget{
  const NoteWidget({super.key});
  @override
  Widget build(BuildContext context){
    return Container(
        
        decoration: BoxDecoration(color: Color.fromARGB(207, 230, 240, 255),
                                  borderRadius: BorderRadius.all(Radius.circular(15))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(onPressed: ()=>null, icon: Icon(Icons.info_outline, color: Color.fromRGBO(33, 53, 207, 1),)),
              Expanded(child: Text("The user will receive an email to activate their account their account and set a password", maxLines: 5,))
            ],
          ),
        ),
      );
  }
}

class ConcludeButtonWidget extends StatelessWidget{
  const ConcludeButtonWidget({super.key});
  @override
  Widget build(BuildContext context){
    return Row(
        children: [
          Spacer(),
          TextButton(
          onPressed: ()=> null,
          style: TextButton.styleFrom(
            backgroundColor:  Colors.white,
            foregroundColor: Colors.black,
          ),
          child: Text("Cancel", style: TextStyle(fontSize: 16),)
          ),

          SizedBox(width: 20,), 

           TextButton(
            
            onPressed: ()=> null,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.blueColor,
              foregroundColor: AppColors.whiteColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12))
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Text("Send Invite", style: TextStyle(fontSize: 16),),
            ),

          )
        ],
      );
  }
}


class CustomDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final String hintText;
  final String Function(T) itemAsString;
  final ValueChanged<T?> onChanged;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.itemAsString,
    required this.onChanged,
    this.hintText = 'Select an option',
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      initialSelection: value,
      hintText: hintText,
      expandedInsets: EdgeInsets.zero, // Forces dropdown to take full width
      onSelected: onChanged,
      textStyle: TextStyle(color: Color.fromARGB(207, 127, 152, 187)),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Color.fromARGB(207, 127, 152, 187)),
        filled: true,
        fillColor: AppColors.lightScaffoldColor,
       
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(177, 197, 225, 1)),
          borderRadius: BorderRadius.all(Radius.circular(10))
          ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(177, 197, 225, 1)),
          borderRadius: BorderRadius.all(Radius.circular(10))
          ),
      ),
      
      dropdownMenuEntries: items.map<DropdownMenuEntry<T>>((T item) {
        return DropdownMenuEntry<T>(
          value: item,
          label: itemAsString(item),
        );
      }).toList(),
      
    );
  }
}
