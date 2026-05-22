class AppItemFields {
  const AppItemFields._();

  static const id = 'id';
  static const listId = 'list_id';
  static const title = 'title';
  static const description = 'description';
  static const status = 'status';
  static const assignmentScope = 'assignment_scope';
  static const position = 'position';
  static const priority = 'priority';
  static const deadlineAt = 'deadline_at';
  static const recurrenceType = 'recurrence_type';
  static const recurrenceInterval = 'recurrence_interval';

  // Movies
  static const movieTmdbId = 'movie_tmdb_id';
  static const movie = 'movie';

  // Books
  static const bookOpenLibraryKey = 'book_open_library_key';
  static const book = 'book';

  // Assignments
  static const assignees = 'assignees';

  // Chores / completion
  static const nextDueAt = 'next_due_at';
  static const createdBy = 'created_by';
  static const completedAt = 'completed_at';
  static const completedBy = 'completed_by';
  static const updatedAt = 'updated_at';
}
