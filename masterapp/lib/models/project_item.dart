class ProjectItem {
  final String title;
  final String subtitle;
  final double progress; // 0..1
  final String status;
  final String priority;
  final int totalTask;
  final int doneTask;
  final String deadline;

  const ProjectItem({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.status,
    required this.priority,
    required this.totalTask,
    required this.doneTask,
    required this.deadline,
  });
}
