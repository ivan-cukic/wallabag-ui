<?php

header('Content-Type: application/json; charset=utf-8');

include('config.php');

$db = new SQLite3($sqlite_database_file, SQLITE3_OPEN_READONLY);

$query = "
        select
            tag.id,
            tag.label,
            tag.slug
        from
            wallabag_tag as tag
    ";

$results = $db->query($query);

$is_first = true;

?>
[
<?php while ($row = $results->fetchArray()) {
    $id       = $row['id'];
    $label    = $row['label'];
    $slug     = $row['slug'];

    $count    = $db->query("select count() from wallabag_entry_tag where tag_id = '$id'");
    $count    = floatval($count->fetchArray()[0]);

    if ($count == 0) continue;

    $level = round(log($count));

    if ($level > 4) $level = 4;

    if ($is_first) {
        $is_first = false;
    } else {
        echo ",";
    }
?>
    {
        "slug"       : <?=json_encode($slug) ?>,
        "title"      : <?=json_encode($label) ?>,
        "post_count" : <?=$count ?>
    }
<?php } ?>
]

