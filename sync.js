require('dotenv').config()
const src = process.env.src
const dist = process.env.dist
// change it to false if you do not want watcher
const watch = process.env.watch

const exclude = [
  /node_modules/,
  /\.git/,
  /package\.json/,
  /package\.lock\.json/,
  /README\.md/,
  /sync\.js/
]

const fs = require('fs')
if (fs.existsSync(src) && fs.existsSync(dist)) {
  // eslint-disable-next-line
  console.log('watcher started')
  require('sync-directory')(src, dist, {
    cb: () => {
      // eslint-disable-next-line
      console.log('src sync done')
    },
    exclude,
    watch
  })
} else {
  // eslint-disable-next-line
  console.log(
    'either src or dist does not exist'
  )
}
