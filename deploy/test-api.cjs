const assert=require('node:assert/strict');
const {randomUUID}=require('node:crypto');
if(process.env.NODE_ENV!=='test'||!process.env.FIREBASE_AUTH_EMULATOR_HOST)throw new Error('Run only in the isolated QA container');
const authMock=require('node:http').createServer(async(req,res)=>{let body='';for await(const chunk of req)body+=chunk;const uid=JSON.parse(body).localId?.[0];res.setHeader('Content-Type','application/json');res.end(JSON.stringify({users:[{localId:uid,disabled:false,validSince:'0'}]}));});
authMock.listen(9099,'127.0.0.1');
const suffix=randomUUID();const uidA='eled-qa-a-'+suffix;const uidB='eled-qa-b-'+suffix;
const base='http://127.0.0.1:3200/api/eled';
function token(uid){const now=Math.floor(Date.now()/1000);return Buffer.from(JSON.stringify({alg:'none',typ:'JWT'})).toString('base64url')+'.'+Buffer.from(JSON.stringify({aud:'eled-aaf5c',iss:'https://securetoken.google.com/eled-aaf5c',sub:uid,iat:now,exp:now+3600,auth_time:now,firebase:{sign_in_provider:'custom',identities:{}}})).toString('base64url')+'.';}
async function request(uid,method='GET',ops){return fetch(base+'/profile',{method,headers:{Authorization:'Bearer '+token(uid),'Content-Type':'application/json'},body:ops?JSON.stringify({operations:ops}):undefined});}
(async()=>{
 for(let i=0;i<20;i++){try{if((await fetch(base+'/health')).ok)break;}catch{}await new Promise(r=>setTimeout(r,500));}
 assert.equal((await fetch(base+'/profile')).status,401);
 const vocabulary=await (await fetch(base+'/vocabulary')).json();assert.ok(vocabulary.length>23000);assert.equal(vocabulary[0][0],'above');
 assert.equal((await request(uidA,'PATCH',[{section:'known',key:'hello',value:true},{section:'collections',key:'QA',value:['hello']}])).status,200);
 assert.equal((await request(uidA)).status,200);assert.equal((await (await request(uidA)).json()).data.known.hello,true);
 assert.deepEqual((await (await request(uidB)).json()).data.known,{});
 await Promise.all([request(uidA,'PATCH',[{section:'known',key:'world',value:true}]),request(uidA,'PATCH',[{section:'custom',key:'phrase',value:'cụm từ'}])]);
 const result=await (await request(uidA)).json();assert.equal(result.data.known.hello,true);assert.equal(result.data.known.world,true);assert.equal(result.data.custom.phrase,'cụm từ');
 assert.equal((await request(uidA,'PATCH',[{section:'secrets',key:'x',value:true}])).status,400);
 assert.equal((await request(uidA,'PATCH',[{section:'collections',key:'QA',value:null}])).status,200);
 assert.deepEqual((await (await request(uidA)).json()).data.collections,{});
 // Only rows with this exact random test UID are removed.
 const {Pool}=require('pg');const pool=new Pool({connectionString:process.env.DATABASE_URL});await pool.query('DELETE FROM eled_profiles WHERE uid=ANY($1)',[[uidA,uidB]]);await pool.end();
 authMock.close();
 console.log('API integration passed: PostgreSQL persistence, auth guard, per-user isolation, concurrent changes, validation and deletion');
})().catch(e=>{console.error(e);process.exit(1)});
