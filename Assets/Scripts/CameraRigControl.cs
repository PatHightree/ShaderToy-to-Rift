using UnityEngine;
using System.Collections;

public class CameraRigControl : MonoBehaviour {
	
	private float _rotSensitivity = 0.1f;
	private float _moveSensitivity = 0.01f;
	private Vector3 _move;
	
	public void Update () {
	    HandleKeyboardInput();
	    HandleMouseInput();
	    HandleSpaceNavigatorInput();
	}

    private void HandleSpaceNavigatorInput() {
        transform.Translate(SpaceNavigator.Instance.GetTranslation(), Space.Self);
        transform.rotation *= SpaceNavigator.Instance.GetRotation();
    }

    private void HandleKeyboardInput() {
        _move = Vector3.zero;
        _move += Input.GetKey(KeyCode.W) ? Vector3.forward : Vector3.zero;
        _move -= Input.GetKey(KeyCode.S) ? Vector3.forward : Vector3.zero;
        _move += Input.GetKey(KeyCode.D) ? Vector3.right : Vector3.zero;
        _move -= Input.GetKey(KeyCode.A) ? Vector3.right : Vector3.zero;
        _move += Input.GetKey(KeyCode.Space) ? Vector3.up : Vector3.zero;
        _move -= Input.GetKey(KeyCode.LeftControl) ? Vector3.up : Vector3.zero;
        _move *= _moveSensitivity;
    }

    private void HandleMouseInput() {
        transform.Translate(_move, Space.Self);
        transform.RotateAround(Vector3.up, Input.GetAxis("Mouse X")*_rotSensitivity);
        transform.RotateAroundLocal(transform.right, -Input.GetAxis("Mouse Y")*_rotSensitivity);
    }
}
