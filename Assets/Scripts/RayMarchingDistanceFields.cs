using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class RayMarchingDistanceFields : MonoBehaviour {

	public Shader rayMarchShader = null;	

	static Material m_Material = null;
	protected Material material {
		get {
			if (m_Material == null) {
				m_Material = new Material(rayMarchShader);
				m_Material.hideFlags = HideFlags.DontSave;
			}
			return m_Material;
		} 
	}
	
	protected void OnDisable() {
		if( m_Material ) {
			DestroyImmediate( m_Material );
		}
	}		
	
	// Called by the camera to apply the image effect
	void OnRenderImage (RenderTexture source, RenderTexture destination) {		
		Graphics.Blit (source, destination, material);
	}	
}
