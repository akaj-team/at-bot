# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

atGithub = require 'at-git-tools'

fs = require 'fs'
configs = JSON.parse(fs.readFileSync('./at-bot-configs.json', 'utf8'))

module.exports = (robot) ->
  # Check users infomation
  robot.respond /\/github-check (.*)/i, (res) ->
    if configs["allowed-room-ids"].indexOf(res.envelope.room) == -1
      res.reply "Room `#{res.envelope.room}` không có quyền truy cập."
      return
    account = res.match[1]
    # console.log res
    if account is "all"
      res.reply "OK, wait a minute."
      atGithub.checkUsers configs.organization, configs["github-access-token"], (result) ->
        res.send "Tổng số nhân viên: #{result.length}"
        res.send createErrorMessage(result)

  robot.hear /test/i, (res) ->
    account = res.match[1]
    console.log res.envelope.room
    res.reply "OK."


# Create slack attachments reports
createErrorMessage = (users) ->
  result = {
    pretext: "New ticket from Andrea Lee",
    attachments: []
    }
  for user in users
    issueCount = 0
    attachment = {
      thumb_url: user.avatarUrl,
      fallback: "",
      text: "<#{user.url}|#{user.login}> - Chưa hợp lệ.",
      fields: [],
      color: getRandomColor()
    }
    for u in user['at-check']
      if u.reports.length > 0
        str = ""
        issueCount += u.reports.length
        for report in u.reports
          str += "- " +report.message + "\n"

        attachment.fields.push({
          title: u.name+"(#{u.value})",
          value: str,
          short: true
          })
    # console.log issueCount
    if issueCount > 0
      result.attachments.push(attachment)
  result

#Get random color
getRandomColor = ->
  letters = '0123456789ABCDEF'
  color = '#'
  i = 0
  while i < 6
    color += letters[Math.floor(Math.random() * 16)]
    i++
  color
