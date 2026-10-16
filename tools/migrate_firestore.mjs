// One-time, read-only Firestore import into PostgreSQL. Requires the Firebase
// CLI to be signed in with access to ELED. Credentials never leave this process.
import {createRequire} from 'node:module';
import {spawnSync} from 'node:child_process';
const require=createRequire(import.meta.url);
const auth=require(process.env.FIREBASE_AUTH_MODULE||'/opt/homebrew/lib/node_modules/firebase-tools/lib/auth');
const account=auth.getGlobalDefaultAccount();
if(!account)throw new Error('Sign in to the Firebase CLI first');
const token=await auth.getAccessToken(account.tokens.refresh_token,[]);
const root='https://firestore.googleapis.com/v1/projects/eled-aaf5c/databases/(default)/documents';
async function list(path){let pageToken;const documents=[];do{const url=new URL(root+'/'+path);url.searchParams.set('pageSize','100');if(pageToken)url.searchParams.set('pageToken',pageToken);const response=await fetch(url,{headers:{Authorization:'Bearer '+token.access_token}});if(!response.ok)throw new Error(`Firestore read failed: ${response.status}`);const data=await response.json();documents.push(...(data.documents||[]));pageToken=data.nextPageToken;}while(pageToken);return documents;}
function decode(v){if('stringValue'in v)return v.stringValue;if('integerValue'in v)return Number(v.integerValue);if('doubleValue'in v)return v.doubleValue;if('booleanValue'in v)return v.booleanValue;if('arrayValue'in v)return(v.arrayValue.values||[]).map(decode);if('mapValue'in v)return Object.fromEntries(Object.entries(v.mapValue.fields||{}).map(([k,v])=>[k,decode(v)]));return null;}
const profiles=[];
for(const doc of await list('users')){
 const uid=doc.name.split('/').at(-1);const fields=Object.fromEntries(Object.entries(doc.fields||{}).map(([k,v])=>[k,decode(v)]));const collections=await list('users/'+encodeURIComponent(uid)+'/collections');const data={known:{},collections:{},srs:{},settings:{firebaseImported:true},speaking:{},custom:{},history:{},activity:{}};
 for(const word of fields.knownWords||[])data.known[word.toLowerCase()]=true;
 for(const col of collections){const name=col.name.split('/').at(-1);data.collections[name]=(decode({mapValue:{fields:col.fields}}).words||[]);}
 const settings=fields.settings||{};if(settings.selectedPopularity)data.settings.levels=settings.selectedPopularity;if(settings.selectedTopics)data.settings.topics=settings.selectedTopics;if(settings.themeMode)data.settings.theme=settings.themeMode;
 (fields.notificationHistory||[]).forEach((w,i)=>data.history[w.split('|')[0].toLowerCase()]=Date.now()-i);
 profiles.push({uid,data});
}
const python=`import json,sys,subprocess
profiles=json.load(sys.stdin)
def quote(s): return "'"+s.replace("'","''")+"'"
parts=[]
for p in profiles:
 sections=['known','collections','srs','settings','speaking','custom','history','activity']
 merge=', '.join(quote(s)+", coalesce(EXCLUDED.data->"+quote(s)+",'{}'::jsonb) || coalesce(eled_profiles.data->"+quote(s)+",'{}'::jsonb)" for s in sections)
 parts.append('INSERT INTO eled_profiles(uid,data) VALUES('+quote(p['uid'])+','+quote(json.dumps(p['data']))+'::jsonb) ON CONFLICT(uid) DO UPDATE SET data=jsonb_build_object('+merge+'),revision=eled_profiles.revision+1,updated_at=now();')
if parts:
 result=subprocess.run(['docker','exec','-i','server-db-1','sh','-c','exec psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d eled'],input='BEGIN;\\n'+'\\n'.join(parts)+'\\nCOMMIT;',text=True,capture_output=True)
 if result.returncode: print('Migration transaction failed');sys.exit(1)
print('Imported',len(profiles),'Firebase profiles into PostgreSQL; source preserved')`;
const command='python3 -c '+"'"+python.replaceAll("'","'\\''")+"'";
const result=spawnSync('ssh',[process.env.ELED_SSH_HOST||'aws-vps',command],{input:JSON.stringify(profiles),encoding:'utf8'});
if(result.status!==0)throw new Error('Migration failed: '+result.stdout.trim());console.log(result.stdout.trim());
