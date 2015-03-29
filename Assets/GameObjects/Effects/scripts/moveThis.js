var translationSpeedX:float=0;
var translationSpeedY:float=1;
var translationSpeedZ:float=0;






function Update () {
//transform.Translate(Vector3(translationSpeedX,translationSpeedY,translationSpeedZ)*Mathf.Sin(Time.deltaTime));
transform.Translate(Vector3(translationSpeedX,0.25*(Mathf.Sin(2*Time.time)),translationSpeedZ));
}