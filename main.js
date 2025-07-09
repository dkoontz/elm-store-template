import './assets/style.css'
import * as ElmDebugger from 'elm-debug-transformer';
import Main from './src/Main.elm'

const flags = {}

ElmDebugger.register({simple_mode: false, debug: true, limit: 10000});

const app = Main.init({flags: flags})

