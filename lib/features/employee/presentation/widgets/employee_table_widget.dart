import 'package:attendance_system_admin/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class MockEmployee {
  final String name;
  final String email;
  final String avatarUrl;
  final String accessLevel;
  final String department;
  final bool isActive;

  const MockEmployee({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.accessLevel,
    required this.department,
    required this.isActive,
  });
}

class EmployeeTableWidget extends StatelessWidget {
  const EmployeeTableWidget({super.key});

  static const List<MockEmployee> mockEmployees = [
    MockEmployee(
      name: 'Marcus Chen',
      email: 'marcus.c@chronos.io',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&auto=format&fit=crop&q=60',
      accessLevel: 'Administrator',
      department: 'Engineering',
      isActive: true,
    ),
    MockEmployee(
      name: 'Sarah Jenkins',
      email: 's.jenkins@chronos.io',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=60',
      accessLevel: 'Operations',
      department: 'Operations',
      isActive: true,
    ),
    MockEmployee(
      name: 'David Miller',
      email: 'd.miller@chronos.io',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=60',
      accessLevel: 'Staff',
      department: 'HR & Admin',
      isActive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final headerStyle = GoogleFonts.quicksand(
      color: Colors.grey.shade500,
      fontWeight: FontWeight.bold,
      fontSize: 12,
      letterSpacing: 0.8,
    );

    return Card(
      elevation: 10,
      shadowColor: AppColors.lightCardShadowColor,
      color: AppColors.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Filters & Pagination Row
            Row(
              children: [
                // Filter: Role: All
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Ionicons.funnel_outline, size: 14, color: Colors.black87),
                        const SizedBox(width: 8),
                        Text(
                          "Role: All",
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Selected filter chip: Engineering
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Engineering",
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(
                          Ionicons.close_outline,
                          size: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Pagination text
                Text(
                  "1-10 of 1,284",
                  style: GoogleFonts.quicksand(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 12),
                // Pagination controls
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Ionicons.chevron_back_outline, size: 16),
                  color: Colors.grey.shade600,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Ionicons.chevron_forward_outline, size: 16),
                  color: Colors.grey.shade600,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 2. Table Headers
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text("MEMBER", style: headerStyle),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text("ACCESS LEVEL", style: headerStyle),
                ),
                Expanded(
                  flex: 3,
                  child: Text("DEPARTMENT", style: headerStyle),
                ),
                Expanded(
                  flex: 2,
                  child: Text("STATUS", style: headerStyle),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade200, height: 1, thickness: 1),
            // 3. Table Rows
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mockEmployees.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade100,
                height: 1,
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final employee = mockEmployees[index];
                return InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
                    child: Row(
                      children: [
                        // Member column
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.blueColor.withAlpha(26),
                                backgroundImage: NetworkImage(employee.avatarUrl),
                                child: Text(
                                  employee.name[0],
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blueColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      employee.name,
                                      style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      employee.email,
                                      style: GoogleFonts.quicksand(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Access level column
                        Expanded(
                          flex: 3,
                          child: Text(
                            employee.accessLevel,
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        // Department column
                        Expanded(
                          flex: 3,
                          child: Text(
                            employee.department,
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        // Status column
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: employee.isActive
                                    ? Colors.green.withAlpha(20)
                                    : Colors.grey.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: employee.isActive
                                          ? AppColors.greenColor
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    employee.isActive ? "Active" : "Inactive",
                                    style: GoogleFonts.quicksand(
                                      color: employee.isActive
                                          ? AppColors.greenColor
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // 4. Load More Button
            Center(
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.blueColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  "Load more members",
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
