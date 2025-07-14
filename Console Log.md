 14-07-2025, 06:51: 
 
X: 
roosterApp.js:276  ❌ Error initializing profile cards: ReferenceError: Cannot access 'initializedElements' before initialization
    at profielkaarten.js:850:17
    at NodeList.forEach (<anonymous>)
    at applyProfileCardHover (profielkaarten.js:848:22)
    at Object.init (profielkaarten.js:824:9)
    at roosterApp.js:274:28
    at commitHookEffectListMount (react-dom.development.js:23199:28)
    at commitPassiveMountOnFiber (react-dom.development.js:24980:13)
    at commitPassiveMountEffects_complete (react-dom.development.js:24940:11)
    at commitPassiveMountEffects_begin (react-dom.development.js:24927:9)
    at commitPassiveMountEffects (react-dom.development.js:24915:5)
(anonymous) @ roosterApp.js:276
commitHookEffectListMount @ react-dom.development.js:23199
commitPassiveMountOnFiber @ react-dom.development.js:24980
commitPassiveMountEffects_complete @ react-dom.development.js:24940
commitPassiveMountEffects_begin @ react-dom.development.js:24927
commitPassiveMountEffects @ react-dom.development.js:24915
flushPassiveEffectsImpl @ react-dom.development.js:27088
flushPassiveEffects @ react-dom.development.js:27033
(anonymous) @ react-dom.development.js:26818
workLoop @ react.development.js:2653
flushWork @ react.development.js:2626
performWorkUntilDeadline @ react.development.js:2920
profielkaarten.js:850  Uncaught ReferenceError: Cannot access 'initializedElements' before initialization
    at profielkaarten.js:850:17
    at NodeList.forEach (<anonymous>)
    at applyProfileCardHover (profielkaarten.js:848:22)
    at Object.init (profielkaarten.js:824:9)
    at roosterApp.js:1443:36
(anonymous) @ profielkaarten.js:850
applyProfileCardHover @ profielkaarten.js:848
init @ profielkaarten.js:824
(anonymous) @ roosterApp.js:1443
setTimeout
(anonymous) @ roosterApp.js:1441
commitHookEffectListMount @ react-dom.development.js:23199
commitPassiveMountOnFiber @ react-dom.development.js:24980
commitPassiveMountEffects_complete @ react-dom.development.js:24940
commitPassiveMountEffects_begin @ react-dom.development.js:24927
commitPassiveMountEffects @ react-dom.development.js:24915
flushPassiveEffectsImpl @ react-dom.development.js:27088
flushPassiveEffects @ react-dom.development.js:27033
(anonymous) @ react-dom.development.js:26818
workLoop @ react.development.js:2653
flushWork @ react.development.js:2626
performWorkUntilDeadline @ react.development.js:2920
