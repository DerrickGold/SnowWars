// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using System.Collections;

namespace TerraVol
{
	public class TerraEditorException : System.Exception
	{
	
		public TerraEditorException ()
		{
		}
	
		public TerraEditorException (string message)
	    : base(message)
		{
		}
	
		public TerraEditorException (string message, System.Exception innerException)
	    : base(message, innerException)
		{
		}
	}
}