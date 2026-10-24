import 'dotenv/config';
import net from 'node:net';
import { Client } from 'ssh2';
import snmp from 'net-snmp';
const base=process.env.AGENT_BASE_URL?.replace(/\/$/,''); const token=process.env.AGENT_TOKEN; const poll=Number(process.env.AGENT_POLL_MS||5000);
const headers={'content-type':'application/json','authorization':`Bearer ${token}`};
async function api(path,opt={}){const r=await fetch(base+path,{...opt,headers:{...headers,...(opt.headers||{})}});return r.json();}
function tcpPing(host,port,timeout=3000){return new Promise(resolve=>{const s=new net.Socket();let done=false;const finish=v=>{if(done)return;done=true;s.destroy();resolve(v)};s.setTimeout(timeout);s.once('connect',()=>finish({ok:true}));s.once('timeout',()=>finish({ok:false,error:'timeout'}));s.once('error',e=>finish({ok:false,error:e.message}));s.connect(port,host)})}
function sshCommand(d,command){return new Promise(resolve=>{const c=new Client();c.on('ready',()=>c.exec(command,(e,stream)=>{if(e){c.end();return resolve({ok:false,error:e.message})}let out='',err='';stream.on('data',x=>out+=x).stderr.on('data',x=>err+=x).on('close',(code)=>{c.end();resolve({ok:code===0,code,stdout:out,stderr:err})})})).on('error',e=>resolve({ok:false,error:e.message})).connect({host:d.ip_address,port:d.port||22,username:d.username,password:d.password,readyTimeout:5000})})}
function snmpGet(host,community,oid='1.3.6.1.2.1.1.3.0'){return new Promise(resolve=>{const s=snmp.createSession(host,community||'public');s.get([oid],(e,varbinds)=>{s.close();if(e)return resolve({ok:false,error:e.message});resolve({ok:true,value:varbinds[0]?.value?.toString()})})})}
async function loop(){try{await api('/api/agent/heartbeat',{method:'POST'});const r=await api('/api/agent/jobs/next');if(r.job){let result={ok:false,error:'unknown'};const d=r.job.device||{};const p=JSON.parse(r.job.payload||'{}');if(r.job.type==='tcp_ping')result=await tcpPing(d.ip_address,d.port||22);if(r.job.type==='ssh_command')result=await sshCommand({...d,...p});if(r.job.type==='snmp_get')result=await snmpGet(d.ip_address,p.community,p.oid);await api(`/api/agent/jobs/${r.job.id}/result`,{method:'POST',body:JSON.stringify({status:result.ok?'done':'failed',result})})}}catch(e){console.error(e)}finally{setTimeout(loop,poll)}}
loop();
