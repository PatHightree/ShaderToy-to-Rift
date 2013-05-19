using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class Appolonian : MonoBehaviour {

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

	private Shader rayMarchShader;

	protected void OnEnable() {
		rayMarchShader = Shader.Find("ShaderToy/IQ Appolonian");
	}
	protected void OnDisable() {
		if( m_Material ) {
			DestroyImmediate( m_Material );
		}
	}		

	// Called by the camera to apply the image effect
	void OnRenderImage (RenderTexture source, RenderTexture destination) {
		
		material.SetVector("iCamPos", transform.position);
		material.SetVector("iCamRight", transform.right);
		material.SetVector("iCamUp", transform.up);
		material.SetVector("iCamForward", transform.forward);
		Graphics.Blit (source, destination, material);
	}
}
