import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class ModifyProfileScreen extends StatefulWidget {
  const ModifyProfileScreen({super.key});

  @override
  _ModifyProfileScreenState createState() => _ModifyProfileScreenState();
}

class _ModifyProfileScreenState extends State<ModifyProfileScreen> {
  final List<bool> _isLunarSelected = [true, false];
  final List<bool> _isGenderSelected = [true, false];

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _birthFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _phone1Focus = FocusNode();
  final FocusNode _phone2Focus = FocusNode();
  final FocusNode _phone3Focus = FocusNode();
  final FocusNode _heightFocus = FocusNode();
  final FocusNode _weightFocus = FocusNode();
  final FocusNode _morningFocus = FocusNode();
  final FocusNode _lunchFocus = FocusNode();
  final FocusNode _dinnerFocus = FocusNode();

  void _toggleLunarSelection(int index) {
    setState(() {
      for (int i = 0; i < _isLunarSelected.length; i++) {
        _isLunarSelected[i] = (i == index);
      }
    });
  }

  void _toggleGenderSelection(int index) {
    setState(() {
      for (int i = 0; i < _isGenderSelected.length; i++) {
        _isGenderSelected[i] = (i == index);
      }
    });
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _birthFocus.dispose();
    _addressFocus.dispose();
    _phone1Focus.dispose();
    _phone2Focus.dispose();
    _phone3Focus.dispose();
    _heightFocus.dispose();
    _weightFocus.dispose();
    _morningFocus.dispose();
    _lunchFocus.dispose();
    _dinnerFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '내 정보 수정', showBackButton: true),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildSection('기본 정보', [
              _buildTextField('이름         ', _nameFocus, _birthFocus),
              _buildDateSelection(),
              _buildGenderSelection(),
              _buildTextField('주소         ', _addressFocus, _phone1Focus),
              _buildPhoneNumberField(),
              _buildHeightWeightField(),
            ]),
            const SizedBox(height: 16),
            _buildSection('추가 정보', [
              _buildTextField('아침시간 ', _morningFocus, _lunchFocus),
              _buildTextField('점심시간 ', _lunchFocus, _dinnerFocus),
              _buildTextField('저녁시간 ', _dinnerFocus, null),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/profile_icon/green_profile.png'),
              ),
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, size: 15, color: Colors.grey),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            child: const Text('이미지 삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, FocusNode focusNode, FocusNode? nextFocusNode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              focusNode: focusNode,
              textInputAction: nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
              onTap: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FocusScope.of(context).requestFocus(focusNode);
                });
              },
              onSubmitted: (_) {
                if (nextFocusNode != null) {
                  FocusScope.of(context).requestFocus(nextFocusNode);
                }
              },
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField('생년월일  ', _birthFocus, _addressFocus),
        ),
        const SizedBox(width: 10),
        ToggleButtons(
          borderRadius: BorderRadius.circular(8),
          constraints: const BoxConstraints(minWidth: 50, minHeight: 40),
          isSelected: _isLunarSelected,
          onPressed: _toggleLunarSelection,
          children: const [
            Text('양력'),
            Text('음력'),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Row(
      children: [
        const Text("성별         ", style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        ToggleButtons(
          borderRadius: BorderRadius.circular(8),
          constraints: const BoxConstraints(minWidth: 50, minHeight: 40),
          isSelected: _isGenderSelected,
          onPressed: _toggleGenderSelection,
          children: const [
            Text('남성'),
            Text('여성'),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Row(
      children: [
        const Text("전화번호", style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: _buildTextField('', _phone1Focus, _phone2Focus)),
        const SizedBox(width: 10),
        const Text("-"),
        Expanded(child: _buildTextField('', _phone2Focus, _phone3Focus)),
        const SizedBox(width: 10),
        const Text("-"),
        Expanded(child: _buildTextField('', _phone3Focus, _heightFocus)),
      ],
    );
  }

  Widget _buildHeightWeightField() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField('신장 (cm)', _heightFocus, _weightFocus),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTextField('체중 (kg)', _weightFocus, _morningFocus),
        ),
      ],
    );
  }
}
