SELECT l.LibraryId AS library_id,
    l.LibPath AS lib_path,
    l.LibType AS lib_type,
    l.LibFormat AS lib_format,
    l.ParentLibraryId AS parent_library_id
FROM Libraries AS l