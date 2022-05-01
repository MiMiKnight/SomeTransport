# 通过昵称模糊查询UID (条件一) tPostAuthor
SELECT
    t.uid AS postAuthorId
    t.nickname AS postAuthorNickname
FROM
    t_dev_info AS t
WHERE
    t.nickname like CONCAT('%',TRIM(#{nickname}),'%')

# 查询主题的作者信息 tTopicAuthor
SELECT
    t.uid AS topicAuthorId
    t.nickname AS topicNickname
FROM
    t_dev_info AS t
WHERE
    t.uid = #{uid}

# 查询未被删除的主题合并主题作者(条件五) tTopic
SELECT
    t1.tid AS topicId,
    t1.fid AS forumId,
    t3.Name AS forumName,
    t1.title AS topicTitle,
    t1.uid AS topicAuthorId,
    t2.nickName AS topicAuthorNickname,
    t1.createTime AS createTime
FROM
    t_forum_topic AS t1
    INNER JOIN t_dev_info AS t2 ON t1.uid = t2.uid
    INNER JOIN t_forum_info AS t3 ON t1.fid = t3.fid
WHERE
    t1.deleted = 0
    AND t1.fid = #{forumId}


# 查询未被删除的帖子表和晒先首位帖（条件二,条件三、条件四）tPost
SELECT
    t.tid AS topicId,
    t.fid AS forumId,
    t.pid AS postId,
    t.uid AS postAuthorId,
    t.content AS postContent,
    t.first AS first,
    t.vedioUrl As postVedioUrl,
    t.createTime as postCreateTime
FROM
    t_forum_post AS t
WHERE
    t.deleted = 0
    AND t.first = #{first}
    AND t.createTime >= #{startTime}
    AND t.createTime <= #{endTime}

# 筛选已经被删除的附件  tAttachment
SELECT
    t.aid AS attachmentId,
    t.pid AS postId,
    t.fileName AS attachmentFileName,
    t.filePath AS attachmentFilePath,
    t.fileType AS attachmentFileType,
    t.file AS attachmentFileType
FROM
    t_forum_attachment AS t
WHERE
    t.is_deleted = 0

# 筛选已经被删除的上传文件  tUpload
SELECT
    t.id AS uploadId,
    t.pid AS postId,
    t.fileName AS uploadFileName,
    t.filePath AS uploadFilePath,
    t.fileType AS uploadFileType,
    t.file AS uploadileType,
FROM
    t_forum_upload AS t
WHERE
    t.is_deleted = 0

# 分页查询
SELECT
    tPost.tid AS topicId,
    tPost.fid AS forumId,
    tPost.pid AS postId,
    tPost.uid AS postAuthorId,
    tPost.content AS postContent,
    tPost.first AS first,
    tPost.vedioUrl As postVedioUrl,
    tPostAuthor.postAuthorId AS postAuthorId,
    tPostAuthor.postNickname AS postAuthorNickname,
    #
    tTopic.forumName AS forumName,
    tTopic.topicAuthorId AS topicAuthorId,
    tTopic.topicAuthorNickname AS topicAuthorNickname,
    tTopic.topicTitle AS topicTitle,
    #
    tAttachment.aid AS attachementId,
    tAttachment.fileName AS tAttachmentFileName,
    tAttachment.fileType AS tAttachmentFileType,
    tAttachment.filePath AS tAttachmentFilePath,
    #
    tUpload.uploadId AS uploadId,
    tUpload.fileName AS uploadFileName,
    tUpload.fileType AS uploadFileType,
    tUpload.filePath AS uploadFilePath
FROM
    () AS postTable
    INNER JOIN () AS tPostAuthor ON tPost.postAuthorId = tPostAuthor.postAuthorId
    INNER JOIN () AS tAttachment ON tPost.postId = tAttachment.postId
    INNER JOIN () AS tUpload ON tPost.postId = tUpload.postId;
    RIGHT JOIN () AS tTopic ON  tPost.postId = tTopic.postId AND tPost.forumId = tTopic.forumId
ORDER BY
    tTopic.topicCreateTime DESC,
    tTopic.topicId ASC,
    tPost.createTime DESC,
    tPost.postId ASC
LIMIT #{(pageNo-1)*pageSize},#{pageSize}

############################################
# 查询未被删除的帖子表和晒先首位帖（条件二,条件三、条件四）tPost
SELECT
    t.tid AS topicId,
    t.fid AS forumId,
    t.pid AS postId,
    t.uid AS postAuthorId,
    t.content AS postContent,
    t.first AS first,
    t.vedioUrl As postVedioUrl,
    t.createTime as postCreateTime
FROM
    t_forum_post AS t
WHERE
    t.deleted = 0
    AND t.first = #{first}
    AND t.createTime >= #{startTime}
    AND t.createTime <= #{endTime}

# 通过昵称模糊查询UID (条件一) tPostAuthor
SELECT
    t.uid AS postAuthorId
    t.nickname AS postAuthorNickname
FROM
    t_dev_info AS t
WHERE
    t.nickname like CONCAT('%',TRIM(#{nickname}),'%')

# 筛选已经被删除的附件  tAttachment
SELECT
    t.aid AS attachmentId,
    t.pid AS postId,
    t.fileName AS attachmentFileName,
    t.filePath AS attachmentFilePath,
    t.fileType AS attachmentFileType,
    t.file AS attachmentFileType
FROM
    t_forum_attachment AS t
WHERE
    t.is_deleted = 0

# 筛选已经被删除的上传文件  tUpload
SELECT
    t.id AS uploadId,
    t.pid AS postId,
    t.fileName AS uploadFileName,
    t.filePath AS uploadFilePath,
    t.fileType AS uploadFileType,
    t.file AS uploadileType,
FROM
    t_forum_upload AS t
WHERE
    t.is_deleted = 0

# 查询未被删除的主题合并主题作者(条件五) tTopic
SELECT
    t1.tid AS topicId,
    t1.fid AS forumId,
    t3.Name AS forumName,
    t1.title AS topicTitle,
    t1.uid AS topicAuthorId,
    t2.nickName AS topicAuthorNickname,
    t1.createTime AS createTime
FROM
    t_forum_topic AS t1
    INNER JOIN t_dev_info AS t2 ON t1.uid = t2.uid
    INNER JOIN t_forum_info AS t3 ON t1.fid = t3.fid
WHERE
    t1.deleted = 0
    AND t1.fid = #{forumId}
