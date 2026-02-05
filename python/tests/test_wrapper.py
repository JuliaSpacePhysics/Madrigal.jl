import pytest

def test_import():
    import madrigal
    assert hasattr(madrigal, "get_instruments")
    assert hasattr(madrigal, "get_experiments")
    assert hasattr(madrigal, "download_file")
