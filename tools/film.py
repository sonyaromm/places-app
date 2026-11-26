import numpy as np, sys
from PIL import Image, ImageFilter
rng=np.random.default_rng(11)
def s_curve(x,c):  # smooth contrast around .5
    return np.clip(.5+(x-.5)*(1+c)-c*4*(x-.5)**3,0,1)
def tone(x,black,white): return black+(white-black)*x
def grain(h,w,size):
    n=rng.normal(0,1,(h,w)).astype(np.float32)
    im=Image.fromarray(((n*36)+128).clip(0,255).astype('uint8')).filter(ImageFilter.GaussianBlur(size))
    return (np.asarray(im).astype(np.float32)-128)/36
def halation(rgb,th,strength,radius,tint):
    lum=rgb.max(2)
    m=np.clip((lum-th)/(1-th),0,1)**1.5
    g=np.asarray(Image.fromarray((m*255).astype('uint8')).filter(ImageFilter.GaussianBlur(radius))).astype(np.float32)/255
    return 1-(1-rgb)*(1-strength*g[...,None]*np.array(tint))
def vignette(h,w,k):
    y,x=np.mgrid[0:h,0:w]; d=np.sqrt(((x-w/2)/(w/2))**2+((y-h/2)/(h/2))**2)/1.414
    return 1-k*np.clip(d-.3,0,1)**1.5
def olive(a,amt):
    r,g,b=a[...,0],a[...,1],a[...,2]
    ex=np.clip(g-np.maximum(r,b),0,1)          # how 'green' a pixel is
    a=a.copy(); a[...,1]-=amt*ex; a[...,0]+=amt*.55*ex; a[...,2]-=amt*.2*ex
    return a
def sat(a,s):
    l=a@np.array([.299,.587,.114]); return l[...,None]+(a-l[...,None])*s
def process(path,look):
    a=np.asarray(Image.open(path).convert('RGB')).astype(np.float32)/255; h,w,_=a.shape
    if look=='hp5':
        bw=a@np.array([.42,.46,.12]); bw=s_curve(bw,.45); bw=tone(bw,.035,.965)
        out=np.repeat(bw[...,None],3,2)*np.array([1.0,.99,.965])
        out=halation(out,.78,.25,9,(1,1,1)); out*=vignette(h,w,.45)[...,None]
        g=grain(h,w,1.0); l=out[...,0]; out+= (g*(.05+.04*(1-np.abs(l-.5)*2)))[...,None]
        return out
    if look=='portra':
        a=a*np.array([1.05,1.0,.92]); a=olive(a,.55); a=sat(a,.88)
        a=s_curve(a,.28)
        out=np.stack([tone(a[...,0],.06,.985),tone(a[...,1],.05,.965),tone(a[...,2],.055,.89)],2)
        l=out@np.array([.299,.587,.114]); out[...,2]+=.03*(1-l)**3; out[...,1]+=.012*(1-l)**3
        out=halation(np.clip(out,0,1),.72,.55,10,(1,.42,.22)); out*=vignette(h,w,.32)[...,None]
        g=grain(h,w,.85); out+=(g*(.03+.03*(1-np.abs(l-.5)*2)))[...,None]
        return out
    if look=='gold':
        a=a*np.array([1.09,1.01,.84]); a=olive(a,.45); a=sat(a,1.12)
        a=s_curve(a,.5)
        out=np.stack([tone(a[...,0],.045,1.0),tone(a[...,1],.035,.97),tone(a[...,2],.03,.86)],2)
        l=out@np.array([.299,.587,.114]); out[...,2]+=.02*(1-l)**3
        out=halation(np.clip(out,0,1),.7,.65,11,(1,.38,.15)); out*=vignette(h,w,.38)[...,None]
        g=grain(h,w,.9); out+=(g*(.035+.035*(1-np.abs(l-.5)*2)))[...,None]
        return out
if __name__=='__main__':
    src,look,dst=sys.argv[1:4]
    Image.fromarray((np.clip(process(src,look),0,1)*255).astype('uint8')).save(dst,quality=90)
