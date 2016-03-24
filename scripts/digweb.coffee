# Description:
#   Like DiG, but in HTTP flavour
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_DIGWEB_HOST
#
# Commands:
#   hubot dig <args> - returns the result of the dig query
#
# Author:
#   @weppos

digwebHost = process.env.HUBOT_DIGWEB_HOST || "https://digweb.herokuapp.com"

module.exports = (robot) ->
  robot.respond /dig (.+)$/i, (msg) ->
    data = msg.match[1].replace /^^(http|https):\/\//g, ""
    msg.http("#{digwebHost}/")
      .headers("User-Agent": "hubot-digweb")
      .post(data) (err, res, body) ->
        message = body.trim()
        message = "```\n#{message}\n```"
        switch res.statusCode
          when 200
            msg.send message
          when 400
            msg.send message
          when 520
            msg.send message
          else
            msg.send "Something strange happened!\n#{message}"
