<?php

header('Content-Type: application/json; charset=utf-8');

include('config.php');

$db = new SQLite3($sqlite_database_file, SQLITE3_OPEN_READONLY);

$tag      = $_GET['tag'];
$all      = isset($_GET['all']);
$untagged = isset($_GET['untagged']);

if (strpos($tag, "'") !== false) {
    exit;
}

$query = "";

if ($tag != "") {
    $query = "
        select
            entry.id,
            entry.title,
            entry.url,
            substr(entry.content, 0, 500) as content,
            entry.preview_picture as picture
        from
            wallabag_entry as entry
        where
            '$tag' in
                (
                    select
                        tag.slug
                    from
                        wallabag_tag as tag
                            join
                        wallabag_entry_tag as et on et.tag_id = tag.id
                    where
                        et.entry_id = entry.id
                )
        ";

} else if ($all) {
    $query = "
        select
            entry.id,
            entry.title,
            entry.url,
            substr(entry.content, 0, 500) as content,
            entry.preview_picture as picture
        from
            wallabag_entry as entry
        ";

} else if ($untagged) {
    $query = "
        select
            entry.id,
            entry.title,
            entry.url,
            substr(entry.content, 0, 500) as content,
            entry.preview_picture as picture
        from
            wallabag_entry as entry
        where
            0 =
                (
                    select
                        count(tag.slug)
                    from
                        wallabag_tag as tag
                            join
                        wallabag_entry_tag as et on et.tag_id = tag.id
                    where
                        et.entry_id = entry.id
                )
        ";


}

$results = $db->query($query);

$is_first = true;

?>
[
    <?php while ($row = $results->fetchArray()) {
        $id      = $row['id'];
        $title   = $row['title'];
        $url     = $row['url'];
        $picture = $row['picture'];
        $content = strip_tags($row['content']);

        if ($is_first) {
            $is_first = false;
        } else {
            echo ",";
        }
    ?>{
        "id"      : <?=json_encode($id) ?>,
        "title"   : <?=json_encode($title) ?>,
        "picture" : <?=json_encode($picture) ?>,
        "content" : <?=json_encode($content) ?>,
        "url"     : <?=json_encode($url) ?>,
        "tags"    : [
    <?php
        $tags = $db->query("
                      select
                          tag.id,
                          tag.label,
                          tag.slug
                      from
                          wallabag_tag as tag
                      join
                          wallabag_entry_tag as et on tag.id = et.tag_id
                      where
                          et.entry_id = '$id'
                      ");

        $is_tag_first = true;

        while ($tag_row = $tags->fetchArray()) {
            $label    = $tag_row['label'];
            $slug     = $tag_row['slug'];

            if ($is_tag_first) {
                echo "            ";
                $is_tag_first = false;
            } else {
                echo ",";
            }
            ?>{ "slug"  : <?=json_encode($slug) ?>, "title" : <?=json_encode($label) ?> } <?php
        } ?> ]
    }
    <?php } ?>
]

